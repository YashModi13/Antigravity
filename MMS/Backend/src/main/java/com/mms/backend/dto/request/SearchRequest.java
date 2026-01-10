package com.mms.backend.dto.request;

import lombok.Data;

@Data
public class SearchRequest {
    private Integer page = 0;
    private Integer size = 10;
    private String sortBy = "id";
    private String sortDir = "asc";
    private Long id; // Filter by ID
}
