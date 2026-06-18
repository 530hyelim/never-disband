package com.neverdisband.service;

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;

/**
 * ao-bin-dumps items.json + formatted/items.txt를 파싱하여 아이템 검색을 제공
 * items.json: XML→JSON 변환 구조, @uniquename / @shopcategory / @shopsubcategory1 포함
 * formatted/items.txt: "index: UNIQUE_NAME : English Name" 형태의 이름 매핑
 */
@Service
public class AlbionItemService {

    private static final Logger logger = LoggerFactory.getLogger(AlbionItemService.class);
    private static final String ITEMS_TXT_URL = "https://raw.githubusercontent.com/ao-data/ao-bin-dumps/master/formatted/items.txt";
    private static final String ITEMS_JSON_URL = "https://raw.githubusercontent.com/ao-data/ao-bin-dumps/master/items.json";

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    private final List<AlbionItem> items = new CopyOnWriteArrayList<>();

    public record AlbionItem(
            String uniqueName,
            String displayName,     // 영문 이름
            String shopCategory,    // weapons, armor, accessories, etc.
            String shopSubCategory  // sword, bow, cloth_helmet, plate_armor, etc.
    ) {}

    @PostConstruct
    public void init() {
        loadItems();
    }

    private void loadItems() {
        try {
            logger.info("Loading Albion items...");

            // 1) formatted/items.txt에서 uniqueName → 영문 이름 매핑
            Map<String, String> nameMap = loadNameMap();
            logger.info("Loaded {} item names from items.txt", nameMap.size());

            // 2) localization.json에서 한글 이름 매핑
            Map<String, String> koreanMap = loadKoreanNames();
            logger.info("Loaded {} Korean item names from localization.json", koreanMap.size());

            // 3) items.json에서 장비 아이템 추출 (카테고리 정보 포함)
            List<AlbionItem> parsed = loadItemsFromJson(nameMap, koreanMap);
            logger.info("Parsed {} equippable items from items.json", parsed.size());

            items.clear();
            items.addAll(parsed);

        } catch (Exception e) {
            logger.error("Failed to load Albion items", e);
        }
    }

    private Map<String, String> loadNameMap() throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(ITEMS_TXT_URL))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            logger.warn("Failed to load items.txt: status={}", response.statusCode());
            return Collections.emptyMap();
        }

        Map<String, String> map = new HashMap<>();
        for (String line : response.body().split("\n")) {
            // 형태: "   1: UNIQUE_NAME                     : English Name"
            String trimmed = line.trim();
            if (trimmed.isEmpty()) continue;

            int firstColon = trimmed.indexOf(':');
            if (firstColon == -1) continue;

            String rest = trimmed.substring(firstColon + 1).trim();
            int secondColon = rest.indexOf(':');
            if (secondColon == -1) continue;

            String uniqueName = rest.substring(0, secondColon).trim();
            String displayName = rest.substring(secondColon + 1).trim();

            if (!uniqueName.isEmpty() && !displayName.isEmpty()) {
                map.put(uniqueName, displayName);
            }
        }
        return map;
    }

    /**
     * localization-items.json에서 한글 이름 매핑 로드
     * 구조: { "tu": [ { "@tuid": "@ITEMS_T8_...", "tuv": [ { "@xml:lang": "KO-KR", "seg": "..." }, ... ] }, ... ] }
     */
    private Map<String, String> loadKoreanNames() {
        Map<String, String> map = new HashMap<>();

        try {
            ClassPathResource resource = new ClassPathResource("localization-items.json");
            if (!resource.exists()) {
                logger.warn("localization-items.json not found in classpath");
                return map;
            }

            JsonFactory factory = new JsonFactory();
            try (JsonParser parser = factory.createParser(resource.getInputStream())) {
                // tu 배열을 찾아서 순회
                while (parser.nextToken() != null) {
                    if (parser.currentToken() == JsonToken.FIELD_NAME && "tu".equals(parser.currentName())) {
                        parser.nextToken(); // START_ARRAY
                        if (parser.currentToken() != JsonToken.START_ARRAY) continue;

                        while (parser.nextToken() != JsonToken.END_ARRAY) {
                            if (parser.currentToken() != JsonToken.START_OBJECT) continue;

                            String tuid = null;
                            String koreanName = null;

                            while (parser.nextToken() != JsonToken.END_OBJECT) {
                                String field = parser.currentName();

                                if ("@tuid".equals(field)) {
                                    parser.nextToken();
                                    tuid = parser.getValueAsString();
                                } else if ("tuv".equals(field)) {
                                    parser.nextToken(); // START_ARRAY
                                    if (parser.currentToken() == JsonToken.START_ARRAY) {
                                        while (parser.nextToken() != JsonToken.END_ARRAY) {
                                            if (parser.currentToken() != JsonToken.START_OBJECT) continue;

                                            String lang = null;
                                            String seg = null;

                                            while (parser.nextToken() != JsonToken.END_OBJECT) {
                                                String tuvField = parser.currentName();
                                                parser.nextToken();

                                                if ("@xml:lang".equals(tuvField)) {
                                                    lang = parser.getValueAsString();
                                                } else if ("seg".equals(tuvField)) {
                                                    seg = parser.getValueAsString();
                                                } else {
                                                    parser.skipChildren();
                                                }
                                            }

                                            if ("KO-KR".equals(lang) && seg != null) {
                                                koreanName = seg;
                                            }
                                        }
                                    } else {
                                        parser.skipChildren();
                                    }
                                } else {
                                    parser.nextToken();
                                    parser.skipChildren();
                                }
                            }

                            if (tuid != null && koreanName != null && tuid.startsWith("@ITEMS_")) {
                                String uniqueName = tuid.substring(7);
                                map.put(uniqueName, koreanName);
                            }
                        }
                        break;
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Failed to parse localization-items.json", e);
        }

        return map;
    }

    private List<AlbionItem> loadItemsFromJson(Map<String, String> nameMap, Map<String, String> koreanMap) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(ITEMS_JSON_URL))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            logger.warn("Failed to load items.json: status={}", response.statusCode());
            return Collections.emptyList();
        }

        JsonNode root = objectMapper.readTree(response.body());
        List<AlbionItem> result = new ArrayList<>();

        // items.json 구조: { "items": { "shopcategories": {...}, "weapon": [...], "equipmentitem": [...], ... } }
        JsonNode itemsNode = root.get("items");
        if (itemsNode == null) return result;

        for (Iterator<Map.Entry<String, JsonNode>> it = itemsNode.fields(); it.hasNext(); ) {
            Map.Entry<String, JsonNode> entry = it.next();
            String key = entry.getKey();
            JsonNode node = entry.getValue();

            // shopcategories, @xmlns 같은 메타데이터는 건너뛰기
            if (key.startsWith("@") || key.startsWith("?") || key.equals("shopcategories")) continue;

            if (node.isArray()) {
                for (JsonNode item : node) {
                    AlbionItem parsed = parseItem(item, nameMap, koreanMap);
                    if (parsed != null) result.add(parsed);
                }
            } else if (node.isObject() && node.has("@uniquename")) {
                AlbionItem parsed = parseItem(node, nameMap, koreanMap);
                if (parsed != null) result.add(parsed);
            }
        }

        return result;
    }

    private AlbionItem parseItem(JsonNode node, Map<String, String> nameMap, Map<String, String> koreanMap) {
        String uniqueName = getAttr(node, "@uniquename");
        if (uniqueName == null || uniqueName.isEmpty()) return null;

        String shopCategory = getAttr(node, "@shopcategory");
        String shopSubCategory = getAttr(node, "@shopsubcategory1");

        // 장비/소비 아이템만 필터
        if (shopCategory == null) return null;
        Set<String> relevantCategories = Set.of(
                "weapons", "offhands", "accessories", "capes",
                "head", "armors", "shoes",
                "consumables"
        );
        if (!relevantCategories.contains(shopCategory)) return null;

        // 설계도(_BP), 저널, UNIQUE_UNLOCK, PROTOTYPE 등 제외
        if (uniqueName.endsWith("_BP") || uniqueName.contains("_JOURNAL_")
                || uniqueName.startsWith("UNIQUE_") || uniqueName.contains("_TOKEN_")
                || uniqueName.contains("PROTOTYPE") || uniqueName.contains("_DEBUG_")
                || uniqueName.contains("_ARENA_") || uniqueName.contains("_BANNER")) return null;

        // 음식은 "food" subcategory만 허용
        if ("consumables".equals(shopCategory)) {
            if (!"food".equals(shopSubCategory)) return null;
        }

        // 한글 이름 우선, 없으면 영문, 없으면 uniqueName
        String displayName = koreanMap.get(uniqueName);
        if (displayName == null || displayName.isEmpty()) {
            displayName = nameMap.getOrDefault(uniqueName, uniqueName);
        }

        return new AlbionItem(uniqueName, displayName, shopCategory, shopSubCategory);
    }

    private String getAttr(JsonNode node, String field) {
        JsonNode val = node.get(field);
        return val != null && !val.isNull() ? val.asText() : null;
    }

    /**
     * 슬롯 타입에 해당하는 무기군(shopSubCategory1) 목록 반환
     */
    public List<Map<String, String>> getSubCategories(String slot) {
        Set<String> shopCats = getSlotFilter(slot);
        if (shopCats == null) return Collections.emptyList();

        // cape, food는 단일 카테고리로 통합
        if ("cape".equalsIgnoreCase(slot) || "food".equalsIgnoreCase(slot)) {
            String label = "cape".equalsIgnoreCase(slot) ? "망토" : "음식";
            return List.of(Map.of("id", "__all__", "name", label));
        }

        return items.stream()
                .filter(item -> {
                    if (item.shopCategory() != null && shopCats.contains(item.shopCategory())) return true;
                    return false;
                })
                .map(AlbionItem::shopSubCategory)
                .filter(Objects::nonNull)
                .filter(sub -> !sub.equals("other") && !sub.equals("labourers") && !sub.equals("unique"))
                .distinct()
                .sorted()
                .map(sub -> Map.of("id", sub, "name", formatSubCategoryName(sub)))
                .collect(Collectors.toList());
    }

    /**
     * 특정 무기군(shopSubCategory1)에 속하는 아이템 목록 반환 (T8만)
     */
    public List<AlbionItem> getItemsBySubCategory(String subCategory) {
        if (subCategory == null || subCategory.isEmpty()) return Collections.emptyList();

        // "__all__"이면 해당 슬롯의 전체 T8 아이템 (cape, food용)
        if ("__all__".equals(subCategory)) return Collections.emptyList();

        String sub = subCategory.toLowerCase();
        return items.stream()
                .filter(item -> sub.equals(item.shopSubCategory()))
                .filter(item -> item.uniqueName().startsWith("T8_"))
                .sorted(Comparator.comparing(AlbionItem::uniqueName))
                .collect(Collectors.toList());
    }

    /**
     * 특정 shopCategory의 모든 T8 아이템 (카테고리 무시, flat 리스트)
     */
    public List<AlbionItem> getItemsByShopCategory(String shopCategory) {
        if (shopCategory == null || shopCategory.isEmpty()) return Collections.emptyList();

        return items.stream()
                .filter(item -> shopCategory.equals(item.shopCategory()))
                .filter(item -> item.uniqueName().startsWith("T8_") ||
                        ("consumables".equals(shopCategory) && item.uniqueName().startsWith("T7_")))
                .sorted(Comparator.comparing(AlbionItem::displayName))
                .collect(Collectors.toList());
    }

    /**
     * shopSubCategory1 ID → 한글 이름 변환
     */
    private String formatSubCategoryName(String sub) {
        if (sub == null) return "";
        return switch (sub.toLowerCase()) {
            case "sword" -> "소드";
            case "bow" -> "활";
            case "crossbow" -> "크로스보우";
            case "axe" -> "도끼";
            case "dagger" -> "대거";
            case "spear" -> "창";
            case "quarterstaff" -> "쿼터스태프";
            case "mace" -> "메이스";
            case "hammer" -> "해머";
            case "knuckles" -> "장갑";
            case "cursestaff" -> "커스드 스태프";
            case "firestaff" -> "파이어 스태프";
            case "froststaff" -> "프로스트 스태프";
            case "arcanestaff" -> "아케인 스태프";
            case "holystaff" -> "홀리 스태프";
            case "naturestaff" -> "네이쳐 스태프";
            case "shapeshifterstaff" -> "셰이프 쉬프터";
            case "shield" -> "방패";
            case "shieldtype" -> "방패";
            case "book" -> "서적";
            case "booktype" -> "서적";
            case "horn" -> "뿔피리";
            case "horntype" -> "뿔피리";
            case "orb" -> "오브";
            case "orbtype" -> "오브";
            case "torch" -> "횃불";
            case "torchtype" -> "횃불";
            case "totem" -> "토템";
            case "totemtype" -> "토템";
            case "cloth_helmet" -> "천 두건";
            case "leather_helmet" -> "가죽 후드";
            case "plate_helmet" -> "판금 헬멧";
            case "unique_helmet" -> "고유 머리";
            case "cloth_armor" -> "천 로브";
            case "leather_armor" -> "가죽 재킷";
            case "plate_armor" -> "판금 아머";
            case "unique_armor" -> "고유 갑옷";
            case "cloth_shoes" -> "천 샌들";
            case "leather_shoes" -> "가죽 신발";
            case "plate_shoes" -> "판금 부츠";
            case "unique_shoes" -> "고유 신발";
            case "capes" -> "망토";
            case "accessoires_capes_bridgewatch" -> "브릿지워치 망토";
            case "accessoires_capes_fortsterling" -> "포트스탈링 망토";
            case "accessoires_capes_lymhurst" -> "림허스트 망토";
            case "accessoires_capes_martlock" -> "마트록 망토";
            case "accessoires_capes_thetford" -> "쎄트포드 망토";
            case "accessoires_capes_caerleon" -> "칼리온 망토";
            case "accessoires_capes_brecilien" -> "브레실리안 망토";
            case "accessoires_capes_smuggler" -> "밀수꾼 망토";
            case "accessoires_capes_avalon" -> "아발론 망토";
            case "accessoires_capes_heretic" -> "이단 망토";
            case "accessoires_capes_undead" -> "언데드 망토";
            case "accessoires_capes_keeper" -> "키퍼 망토";
            case "accessoires_capes_morgana" -> "모르가나 망토";
            case "accessoires_capes_demon" -> "악마 망토";
            case "accessoires_capes_fey" -> "페이 망토";
            case "bag" -> "가방";
            case "cooked" -> "음식";
            case "food" -> "음식";
            case "potion" -> "물약";
            default -> {
                String name = sub.replace("_", " ");
                yield name.substring(0, 1).toUpperCase() + name.substring(1);
            }
        };
    }

    /**
     * 슬롯별 필터 — shopCategory 또는 shopSubCategory1 매칭
     */
    private Set<String> getSlotFilter(String slot) {
        if (slot == null || slot.isEmpty()) return null;

        return switch (slot.toLowerCase()) {
            case "weapon" -> Set.of("weapons");
            case "offhand" -> Set.of("offhands");
            case "head" -> Set.of("head");
            case "chest" -> Set.of("armors");
            case "shoes" -> Set.of("shoes");
            case "cape" -> Set.of("capes");
            case "food" -> Set.of("consumables");
            default -> null;
        };
    }

    public boolean isLoaded() {
        return !items.isEmpty();
    }

    /**
     * 여러 uniqueName에 대해 displayName 매핑 반환
     */
    public Map<String, String> getDisplayNames(List<String> uniqueNames) {
        if (uniqueNames == null || uniqueNames.isEmpty()) return Collections.emptyMap();
        Set<String> nameSet = new HashSet<>(uniqueNames);
        Map<String, String> result = new HashMap<>();
        items.stream()
                .filter(item -> nameSet.contains(item.uniqueName()))
                .forEach(item -> result.put(item.uniqueName(), item.displayName()));
        // 매핑 안 된 건 원래 이름 유지
        for (String name : uniqueNames) {
            result.putIfAbsent(name, name);
        }
        return result;
    }
}
