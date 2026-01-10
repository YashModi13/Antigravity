package com.mms.backend.dto.request;

import lombok.Data;

@Data
public class CommonRequest {
    private String period; // For charts
    private Integer tokenNo; // For token check
    private Integer count; // For seeding
    private Long id; // Generic long ID
}
