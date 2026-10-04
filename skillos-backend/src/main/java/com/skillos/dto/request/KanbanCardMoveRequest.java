package com.skillos.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class KanbanCardMoveRequest {
    @NotNull(message = "Target column ID is required")
    private Long targetColumnId;

    @NotNull(message = "Target order index is required")
    private Integer targetOrderIndex;
}
