package com.neverdisband.controller;

import com.neverdisband.service.AlbionItemService;
import com.neverdisband.service.AlbionItemService.AlbionItem;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/items")
public class ItemController {

    private final AlbionItemService itemService;

    public ItemController(AlbionItemService itemService) {
        this.itemService = itemService;
    }

    /**
     * 슬롯별 무기군(서브카테고리) 목록 조회
     * GET /api/items/categories?slot=weapon
     */
    @GetMapping("/categories")
    public ResponseEntity<?> categories(
            @RequestParam(required = false, defaultValue = "weapon") String slot
    ) {
        if (!itemService.isLoaded()) {
            return ResponseEntity.ok(List.of());
        }
        return ResponseEntity.ok(itemService.getSubCategories(slot));
    }

    /**
     * 특정 무기군의 세부 아이템 목록 조회
     * GET /api/items/byCategory?subCategory=sword&slot=weapon
     */
    @GetMapping("/byCategory")
    public ResponseEntity<?> byCategory(
            @RequestParam String subCategory,
            @RequestParam(required = false, defaultValue = "") String slot
    ) {
        if (!itemService.isLoaded()) {
            return ResponseEntity.ok(List.of());
        }

        List<AlbionItem> results;
        if ("__all__".equals(subCategory) && !slot.isEmpty()) {
            // cape, food 등 flat 리스트
            String shopCat = switch (slot.toLowerCase()) {
                case "cape" -> "capes";
                case "food" -> "consumables";
                default -> "";
            };
            results = itemService.getItemsByShopCategory(shopCat);
        } else {
            results = itemService.getItemsBySubCategory(subCategory);
        }

        List<Map<String, String>> response = results.stream()
                .map(item -> (Map<String, String>) Map.of(
                        "uniqueName", item.uniqueName(),
                        "localizedName", item.displayName()
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    /**
     * uniqueName 목록에 대한 displayName 매핑 조회
     * POST /api/items/names
     * body: ["T8_MAIN_SWORD", "T8_HEAD_CLOTH_SET1", ...]
     */
    @PostMapping("/names")
    public ResponseEntity<?> getNames(@RequestBody List<String> uniqueNames) {
        if (!itemService.isLoaded()) return ResponseEntity.ok(Map.of());
        return ResponseEntity.ok(itemService.getDisplayNames(uniqueNames));
    }
}
