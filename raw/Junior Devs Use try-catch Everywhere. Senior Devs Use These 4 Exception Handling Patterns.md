---
title: Junior Devs Use try-catch Everywhere. Senior Devs Use These 4 Exception Handling Patterns | by Habibwahid | in Stackademic
source: https://freedium-mirror.cfd/medium.com/stackademic/junior-devs-use-try-catch-everywhere-senior-devs-use-these-4-exception-handling-patterns-dcd869ed6551
author:
  - "[[Habib Wahid]]"
published:
created: 2026-05-09
description: Try-catch on every method? That's not safe code — that's a ticking time bomb. Here's...
tags:
  - clippings
---
[< Go to the original](https://blog.stackademic.com/junior-devs-use-try-catch-everywhere-senior-devs-use-these-4-exception-handling-patterns-dcd869ed6551#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*7seiGDAW_yeQLR__Yt3vPA.png)

## Junior Devs Use try-catch Everywhere. Senior Devs Use These 4 Exception Handling Patterns

## Try-catch on every method? That's not safe code — that's a ticking time bomb. Here's what senior devs do instead.[Stackademic](https://medium.com/stackademic "Stackademic is a learning hub for programmers, devs…")a11y-light ~6 min read · February 1, 2026 (Updated: February 1, 2026) · Free: No

I joined a startup two years ago. The codebase had try-catch blocks wrapping every single method — controllers, services, repositories, and utility classes. Everything. The team called it "safe coding."

It wasn't safe. It was a disaster waiting to happen.

Within three months, we had three production incidents where errors vanished silently. No logs. No alerts. No way to know something broke until a customer complains. The try-catch blocks didn't protect us. They *hid* the problems from us.

That experience taught me one thing: **wrapping everything in try-catch isn't defensive programming. It's fear-based programming.** Senior developers don't reach for try-catch first. They reach for it last — only when it's the only right tool for the job.

Here's exactly what that looks like in code.

### Why Junior Devs Default to try-catch

It makes sense on the surface. Something might fail? Wrap it. Compiler complains? Add a catch block. The tutorial shows a try-catch. Copy it.

The problem is that try-catch is a reactive tool, not a preventive one**.** Every time you wrap code in try-catch, you're saying: "I don't know what will go wrong here, so I'll just catch whatever happens."

Senior devs ask a different question first: *Can I prevent this from going wrong in the first place?*

### The 4 Patterns Senior Devs Use Instead

### Pattern 1: Validate First, Catch Never

The most common reason junior devs add try-catch is to handle invalid input. A null value comes in, something breaks, and the catch block saves the day.

```java
// ❌ WRONG — Catching what validation should have prevented
@PostMapping("/users")
public ResponseEntity<User> createUser(@RequestBody UserRequest request) {
    try {
        User user = userService.create(request);
        return ResponseEntity.ok(user);
    } catch (NullPointerException e) {
        return ResponseEntity.badRequest().body(null);
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(null);
    }
}
```

**What Senior Devs Do Instead:**

```java
// ✅ CORRECT - Validate at the door. Nothing bad gets inside.
@PostMapping("/users")
public ResponseEntity<User> createUser(@Valid @RequestBody UserRequest request) {
    User user = userService.create(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(user);
}

// The request object itself enforces the rules
public class UserRequest {
    @NotBlank(message = "Name is required")
    private String name;
    @Email(message = "Must be a valid email")
    @NotNull(message = "Email is required")
    private String email;
    @Min(value = 18, message = "Must be at least 18")
    private int age;
}
```

Senior devs never let invalid input reach the point where it breaks.

**The Rule: If you're catching an exception caused by bad input, you have a validation problem — not an exception handling problem.**

### Pattern 2: A Custom Exception Hierarchy

Junior devs catch `Exception`. Senior devs build a hierarchy that makes every failure *self-explanatory*.

```kotlin
// ❌ WRONG — Generic exceptions tell you nothing
try {
    orderService.process(order);
} catch (Exception e) {
    logger.error("Something failed: " + e.getMessage());
    return ResponseEntity.internalServerError().build();
}
```

**What Senior Devs Do Instead:**

```java
// ✅ CORRECT - A structured exception hierarchy
// Base exception - all app exceptions extend this
public class AppException extends RuntimeException {
    private final HttpStatus status;
    private final String errorCode;
    public AppException(String message, HttpStatus status, String errorCode) {
        super(message);
        this.status = status;
        this.errorCode = errorCode;
    }
}

// Specific exceptions speak for themselves
public class NotFoundException extends AppException {
    public NotFoundException(String resource, Long id) {
        super(resource + " not found with id: " + id, HttpStatus.NOT_FOUND, "NOT_FOUND");
    }
}

public class BusinessRuleViolatedException extends AppException {
    public BusinessRuleViolatedException(String rule) {
        super("Business rule violated: " + rule, HttpStatus.CONFLICT, "BUSINESS_RULE_VIOLATED");
    }
}

// Usage - no try-catch needed in the service
public Order processOrder(OrderRequest request) {
    Order order = orderRepository.findById(request.getOrderId())
        .orElseThrow(() -> new NotFoundException("Order", request.getOrderId()));
    if (order.isAlreadyProcessed()) {
        throw new BusinessRuleViolatedException("Order already processed");
    }
    return orderRepository.save(order);
}
```

When `NotFoundException` gets thrown, you already know *what* failed, *why* it failed, and *what HTTP status* to return. Zero guesswork.

**The Rule: If you're catching a generic exception and then trying to figure out what actually went wrong, your exceptions aren't specific enough.**

### Pattern 3: @ControllerAdvice — Handle Exceptions in One Place

Junior devs put try-catch in every controller method. Senior devs handle all exceptions in a single, centralized place.

```kotlin
// ❌ WRONG — Copy-pasting the same catch logic across 15 controllers
@GetMapping("/orders/{id}")
public ResponseEntity<Order> getOrder(@PathVariable Long id) {
    try {
        return ResponseEntity.ok(orderService.findById(id));
    } catch (NotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().build();
    }
}
```

**What Senior Devs Do Instead:**

```java
// ✅ CORRECT - One handler. All controllers. Zero duplication.
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(NotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getErrorCode(), e.getMessage()));
    }

    @ExceptionHandler(BusinessRuleViolatedException.class)
    public ResponseEntity<ErrorResponse> handleBusinessRule(BusinessRuleViolatedException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(new ErrorResponse(e.getErrorCode(), e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException e) {
        String details = e.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse("VALIDATION_FAILED", details));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnexpected(Exception e) {
        logger.error("Unexpected error", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse("INTERNAL_ERROR", "Something went wrong"));
    }
}

// Now your controllers look like THIS
@GetMapping("/orders/{id}")
public Order getOrder(@PathVariable Long id) {
    return orderService.findById(id);  // Exceptions handle themselves
}
```

Your controllers become clean. Thin. Readable. All the error logic lives in one file.

**The Rule: If you're writing the same catch block in more than one controller, you need a @ControllerAdvice.**

### Pattern 4: Result Objects for Expected Failures

Not every failure is exceptional. "User not found" isn't an error — it's a normal outcome. Using exceptions for normal outcomes is like using an ambulance to get to work.

```java
// ❌ WRONG — Throwing exceptions for expected scenarios
public User findUser(Long id) {
    return userRepository.findById(id)
        .orElseThrow(() -> new NotFoundException("User", id));
}

// Now every caller needs to handle this exception
```

**What Senior Devs Do Instead:**

```java
// ✅ CORRECT - Result objects communicate success and failure explicitly
public class Result<T> {
    private final T value;
    private final String error;
    private final boolean success;
    private Result(T value, String error, boolean success) {
        this.value = value;
        this.error = error;
        this.success = success;
    }

    public static <T> Result<T> ok(T value) {
        return new Result<>(value, null, true);
    }

    public static <T> Result<T> failure(String error) {
        return new Result<>(null, error, false);
    }

    public boolean isSuccess() { return success; }
    public T getValue() { return value; }
    public String getError() { return error; }
}

// Usage - no exceptions, no guessing
public Result<User> findUser(Long id) {
    return userRepository.findById(id)
        .map(Result::ok)
        .orElse(Result.failure("User not found with id: " + id));
}

// Caller knows exactly what happened
Result<User> result = userService.findUser(123L);
if (result.isSuccess()) {
    return ResponseEntity.ok(result.getValue());
}

return ResponseEntity.notFound().build();
```

**The Rule: If a scenario is expected — not a bug, not a system failure — don't throw an exception. Return a Result.**

### The Mental Model That Changes Everything

Senior developers think about exceptions in two categories:

**Exceptional** = Something that *should not* happen under normal conditions. A database connection drops. A third-party API times out. The server runs out of memory. These deserve try-catch, logging, and alerts.

**Expected** = Something that *can* happen as part of normal business logic. A user doesn't exist. An order has already shipped. A payment is declined. These deserve validation, Result objects, and clean control flow — not try-catch.

Once you start categorizing failures this way, you'll naturally write fewer try-catch blocks. Not because you're ignoring errors. Because you're handling them *better*.

### Your Action Plan for Tomorrow

Find one try-catch in your codebase that's catching bad input — replace it with `@Valid` a proper annotation. Pick one generic `catch (Exception e)` — replace it with a specific custom exception. If you have catch blocks repeating across controllers — build a `@ControllerAdvice`. Find one place where you throw an exception for an expected scenario — replace it with a Result object.

Don't refactor everything at once. Start with one. Each change makes your code more honest about what's actually happening — and that's the real difference between junior and senior exception handling.

What's the worst try-catch block you've ever seen in a production codebase? Drop it in the comments — I guarantee someone on this thread has seen worse.

[< Go to the original](https://blog.stackademic.com/junior-devs-use-try-catch-everywhere-senior-devs-use-these-4-exception-handling-patterns-dcd869ed6551#bypass)