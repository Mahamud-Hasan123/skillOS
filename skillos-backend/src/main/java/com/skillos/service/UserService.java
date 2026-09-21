package com.skillos.service;

import com.skillos.dto.request.ChangePasswordRequest;
import com.skillos.dto.request.DeleteAccountRequest;
import com.skillos.dto.request.UpdateProfileRequest;
import com.skillos.dto.response.UserProfileResponse;
import com.skillos.entity.User;
import com.skillos.exception.IncorrectPasswordException;
import com.skillos.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserProfileResponse getUserProfile(User user) {
        return mapToProfileResponse(user);
    }

    public UserProfileResponse updateProfile(User user, UpdateProfileRequest request) {
        if (request.getFullName() != null) user.setFullName(request.getFullName());
        if (request.getAvatar() != null) user.setAvatar(request.getAvatar());
        if (request.getBio() != null) user.setBio(request.getBio());
        if (request.getTimezone() != null) user.setTimezone(request.getTimezone());
        if (request.getProfession() != null) user.setProfession(request.getProfession());
        
        userRepository.save(user);
        return mapToProfileResponse(user);
    }

    public void changePassword(User user, ChangePasswordRequest request) {
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new IncorrectPasswordException("Incorrect current password");
        }
        
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public void deleteAccount(User user, DeleteAccountRequest request) {
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IncorrectPasswordException("Incorrect password");
        }
        
        userRepository.delete(user);
    }

    private UserProfileResponse mapToProfileResponse(User user) {
        return UserProfileResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole())
                .avatar(user.getAvatar())
                .bio(user.getBio())
                .profession(user.getProfession())
                .timezone(user.getTimezone())
                .currentLevel(1)
                .totalXp(0)
                .apBalance(0)
                .createdAt(user.getCreatedAt())
                .build();
    }
}
