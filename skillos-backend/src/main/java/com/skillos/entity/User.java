package com.skillos.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
@com.fasterxml.jackson.annotation.JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Column(nullable = false)
    private String passwordHash;

    // Database schema: enum('user','admin','super_admin')
    @Builder.Default
    private String role = "user";

    @Builder.Default
    private String avatar = "preset_01";

    private String bio;

    @Builder.Default
    @Column(nullable = false)
    private String timezone = "UTC";

    // Database schema: enum('student','self_learner','professional')
    @Builder.Default
    private String profession = "student";

    @Builder.Default
    private Boolean emailVerified = false;

    @Builder.Default
    private Boolean onboardingCompleted = false;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    // --- UserDetails Methods ---

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()));
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public String getPassword() {
        return passwordHash;
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public String getUsername() {
        return email; // We use email for login
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @Override
    public boolean isEnabled() {
        return true;
    }
}
