package com.skillos.repository;

import com.skillos.entity.UserXp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserXpRepository extends JpaRepository<UserXp, Long> {
    Optional<UserXp> findByUserId(Long userId);
}
