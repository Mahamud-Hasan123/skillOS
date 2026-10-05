package com.skillos.service;

import com.skillos.dto.request.GanttEntryUpdateRequest;
import com.skillos.entity.GanttEntry;
import com.skillos.entity.User;
import com.skillos.repository.GanttEntryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GanttService {

    private final GanttEntryRepository ganttEntryRepository;

    public List<GanttEntry> getProjectGanttEntries(Long projectId, User user) {
        return ganttEntryRepository.findByProjectIdOrderByOrderIndexAsc(projectId);
    }

    @Transactional
    public GanttEntry updateGanttEntry(Long id, GanttEntryUpdateRequest request, User user) {
        GanttEntry entry = ganttEntryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Gantt entry not found"));

        // Only owner should modify (checking project ownership)
        if (!entry.getProject().getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Not authorized");
        }

        if (request.getStartDay() != null) {
            entry.setStartDay(request.getStartDay());
        }
        if (request.getDurationDays() != null) {
            entry.setDurationDays(request.getDurationDays());
        }

        // Handle reordering if orderIndex is provided
        if (request.getOrderIndex() != null && !request.getOrderIndex().equals(entry.getOrderIndex())) {
            List<GanttEntry> entries = ganttEntryRepository.findByProjectIdOrderByOrderIndexAsc(entry.getProject().getId());
            entries.removeIf(e -> e.getId().equals(entry.getId()));
            
            int targetIdx = Math.min(request.getOrderIndex(), entries.size());
            targetIdx = Math.max(0, targetIdx);
            entries.add(targetIdx, entry);

            for (int i = 0; i < entries.size(); i++) {
                GanttEntry e = entries.get(i);
                e.setOrderIndex(i);
                ganttEntryRepository.save(e);
            }
        } else {
            ganttEntryRepository.save(entry);
        }

        return entry;
    }
}
