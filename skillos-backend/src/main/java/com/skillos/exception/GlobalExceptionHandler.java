package com.skillos.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        FieldError firstError = ex.getBindingResult().getFieldErrors().stream().findFirst().orElse(null);

        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("code", "VALIDATION_ERROR");

        if (firstError != null) {
            errorDetails.put("message", firstError.getDefaultMessage());
            errorDetails.put("field", firstError.getField());
        } else {
            errorDetails.put("message", "Validation failed");
        }

        Map<String, Object> response = new HashMap<>();
        response.put("error", errorDetails);

        return new ResponseEntity<>(response, HttpStatus.UNPROCESSABLE_ENTITY);
    }

    @ExceptionHandler(DuplicateEmailException.class)
    public ResponseEntity<Map<String, Object>> handleDuplicateEmailException(DuplicateEmailException ex) {
        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("code", "CONFLICT");
        errorDetails.put("message", ex.getMessage());
        errorDetails.put("field", "email");

        Map<String, Object> response = new HashMap<>();
        response.put("error", errorDetails);

        return new ResponseEntity<>(response, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleResourceNotFoundException(ResourceNotFoundException ex) {
        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("code", "NOT_FOUND");
        errorDetails.put("message", ex.getMessage());

        Map<String, Object> response = new HashMap<>();
        response.put("error", errorDetails);

        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGlobalException(Exception ex) {
        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("code", "INTERNAL_SERVER_ERROR");
        errorDetails.put("message", ex.getMessage() != null ? ex.getMessage() : "An unexpected error occurred");

        Map<String, Object> response = new HashMap<>();
        response.put("error", errorDetails);

        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
