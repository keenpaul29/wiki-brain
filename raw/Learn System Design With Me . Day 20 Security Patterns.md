---
title: "Learn System Design With Me . Day 20: Security Patterns"
source: "https://archive.is/mxIBa"
author:
  - "[[The Latency Gambler]]"
published: 2025-11-01
created: 2026-06-14
description:
tags:
  - "clippings"
---
*Welcome back! If you’re just joining, start with* [*Day 1: Building Your Architect Mindset*](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build your foundation.*

I once deployed a feature on Friday evening. Felt great. Went home. Saturday morning, my phone exploded with alerts. Someone had figured out they could change a single URL parameter and access ANY user’s data. We had 50,000 users. By the time we patched it, 12,000 accounts had been accessed.

![](https://df1hm8afsb764m.archive.is/mxIBa/f34e7c55b542c3802002aae39ea98dfe03246b5b.webp)

Ai Generated Image

That day taught me: **security isn’t a feature you add later. It’s the foundation you build on.** A fast, scalable system that leaks data is worse than no system at all.

Today, we’re diving deep into security patterns, the shields that protect your users, your data, and your career.

### The Security Mindset Shift

Before we dive in, understand this: **security is about layers**. No single pattern makes you secure. You need defense in depth, multiple barriers so that when (not if) one fails, others still protect you.

```html
Security Layers (Defense in Depth):
┌─────────────────────────────────────────┐
│  Network Security (Firewall, DDoS)      │
├─────────────────────────────────────────┤
│  Transport Security (HTTPS, TLS)        │
├─────────────────────────────────────────┤
│  Authentication (Who are you?)          │
├─────────────────────────────────────────┤
│  Authorization (What can you do?)       │
├─────────────────────────────────────────┤
│  Data Encryption (At rest & in transit) │
├─────────────────────────────────────────┤
│  Audit Logging (Who did what, when?)    │
└─────────────────────────────────────────┘
```

### Authentication Patterns: Proving Who You Are

Authentication answers one question: “Are you who you claim to be?” Let’s explore the patterns from basic to bulletproof.

### Pattern 1: Session-Based Authentication (The Traditional Way)

```html
@RestController
public class AuthController {
    @Autowired
    private SessionRepository sessionRepository;
    
    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        // Verify credentials
        User user = userService.authenticate(
            request.getEmail(), 
            request.getPassword()
        );
        
        if (user == null) {
            throw new UnauthorizedException("Invalid credentials");
        }
        
        // Create session
        String sessionId = UUID.randomUUID().toString();
        Session session = new Session(sessionId, user.getId(), 
            LocalDateTime.now().plusHours(24));
        sessionRepository.save(session);
        
        // Return session cookie
        return new LoginResponse(sessionId);
    }
    
    @GetMapping("/profile")
    public User getProfile(@CookieValue("SESSION_ID") String sessionId) {
        Session session = sessionRepository.findById(sessionId)
            .orElseThrow(() -> new UnauthorizedException("Invalid session"));
        
        if (session.isExpired()) {
            throw new UnauthorizedException("Session expired");
        }
        
        return userService.getUser(session.getUserId());
    }
}
```

**Architecture:**

```html
Client                          Server
  │                              │
  │  POST /login (email, pwd)    │
  ├─────────────────────────────>│
  │                              │ Store session in DB/Redis
  │  200 OK (SESSION_ID cookie)  │
  │<─────────────────────────────┤
  │                              │
  │  GET /profile                │
  │  Cookie: SESSION_ID=abc123   │
  ├─────────────────────────────>│
  │                              │ Lookup session in store
  │  200 OK (user data)          │
  │<─────────────────────────────┤
```

**Pros:** Simple, server controls everything  
**Cons:** Doesn’t scale horizontally (session store becomes bottleneck), not suitable for microservices

### Pattern 2: JWT (JSON Web Tokens) The Stateless Revolution

JWT changed the game by making authentication stateless. No server-side session storage needed.

```html
@Service
public class JWTService {
    @Value("${jwt.secret}")
    private String secretKey;
    
    public String generateToken(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId());
        claims.put("email", user.getEmail());
        claims.put("roles", user.getRoles());
        
        return Jwts.builder()
            .setClaims(claims)
            .setSubject(user.getEmail())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 3600000)) // 1 hour
            .signWith(SignatureAlgorithm.HS256, secretKey)
            .compact();
    }
    
    public Claims validateToken(String token) {
        try {
            return Jwts.parser()
                .setSigningKey(secretKey)
                .parseClaimsJws(token)
                .getBody();
        } catch (JwtException e) {
            throw new UnauthorizedException("Invalid token");
        }
    }
}

@Component
public class JWTAuthenticationFilter extends OncePerRequestFilter {
    @Autowired
    private JWTService jwtService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain filterChain) {
        String authHeader = request.getHeader("Authorization");
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            Claims claims = jwtService.validateToken(token);
            
            // Set authentication context
            Authentication auth = new JWTAuthentication(claims);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        
        filterChain.doFilter(request, response);
    }
}
```

**JWT Structure:**

```html
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NSIsImVtYWlsIjoidXNlckBleGFtcGxlLmNvbSIsInJvbGVzIjpbIlVTRVIiXSwiaWF0IjoxNjM1MDc3MTIwLCJleHAiOjE2MzUwODA3MjB9.4TFcy4FZsVGGMvPK7H2RlLX5xJdEb8qOGE0n3dEqAbc

Header.Payload.Signature

Header:  {"alg": "HS256", "typ": "JWT"}
Payload: {"userId": "12345", "email": "user@example.com", "roles": ["USER"]}
Signature: HMACSHA256(base64(header) + "." + base64(payload), secret)
```

**Critical JWT Security Rules:**

1. **Never store sensitive data in JWT** (it’s base64 encoded, not encrypted!)
2. **Use short expiration times** (15–60 minutes)
3. **Implement refresh tokens** for long-lived sessions
4. **Validate signature ALWAYS**

### Pattern 3: OAuth 2.0 Delegated Authorization

OAuth lets users log in with Google, GitHub, etc. without sharing passwords.

```html
OAuth 2.0 Flow (Authorization Code):
```
```html
User                  Your App              Google (OAuth Provider)
 │                      │                         │
 │  1. Click "Login     │                         │
 │     with Google"     │                         │
 ├─────────────────────>│                         │
 │                      │                         │
 │  2. Redirect to      │                         │
 │     Google login     │                         │
 │<─────────────────────┤                         │
 │                      │                         │
 │  3. Enter credentials│                         │
 ├──────────────────────┼────────────────────────>│
 │                      │                         │
 │  4. Authorization    │                         │
 │     code             │                         │
 │<─────────────────────┼─────────────────────────┤
 │                      │                         │
 │  5. Send code        │                         │
 ├─────────────────────>│                         │
 │                      │  6. Exchange code       │
 │                      │     for access token    │
 │                      ├────────────────────────>│
 │                      │                         │
 │                      │  7. Access token        │
 │                      │<────────────────────────┤
 │                      │                         │
 │  8. Logged in!       │                         │
 │<─────────────────────┤                         │
```
```html
@RestController
public class OAuthController {
    @GetMapping("/oauth/google")
    public void redirectToGoogle(HttpServletResponse response) {
        String googleAuthUrl = "https://accounts.google.com/o/oauth2/v2/auth?"
            + "client_id=" + clientId
            + "&redirect_uri=" + redirectUri
            + "&response_type=code"
            + "&scope=openid email profile";
        
        response.sendRedirect(googleAuthUrl);
    }
    
    @GetMapping("/oauth/callback")
    public LoginResponse handleCallback(@RequestParam String code) {
        // Exchange code for access token
        OAuth2AccessToken token = restTemplate.postForObject(
            "https://oauth2.googleapis.com/token",
            new TokenRequest(code, clientId, clientSecret, redirectUri),
            OAuth2AccessToken.class
        );
        
        // Get user info
        GoogleUserInfo userInfo = restTemplate.getForObject(
            "https://www.googleapis.com/oauth2/v1/userinfo?access_token=" 
                + token.getAccessToken(),
            GoogleUserInfo.class
        );
        
        // Create or update user in your system
        User user = userService.findOrCreateByEmail(userInfo.getEmail());
        
        // Generate your own JWT for this user
        String jwt = jwtService.generateToken(user);
        return new LoginResponse(jwt);
    }
}
```

### Authorization Patterns: Controlling What You Can Do

Authentication proves identity. Authorization determines permissions. Big difference.

### Pattern 1: RBAC (Role-Based Access Control)

Users have roles. Roles have permissions. Simple and effective for most applications.

```html
@Entity
public class User {
    private String id;
    private String email;
    
    @ManyToMany
    private Set<Role> roles; // ADMIN, USER, MODERATOR
}

@Entity
public class Role {
    private String name;
    
    @ManyToMany
    private Set<Permission> permissions; // READ_POST, WRITE_POST, DELETE_POST
}

// Authorization check
@Service
public class AuthorizationService {
    public boolean hasPermission(User user, String permission) {
        return user.getRoles().stream()
            .flatMap(role -> role.getPermissions().stream())
            .anyMatch(p -> p.getName().equals(permission));
    }
}

// Usage with annotations
@RestController
public class PostController {
    @GetMapping("/posts/{id}")
    @RequiresPermission("READ_POST")
    public Post getPost(@PathVariable String id) {
        return postService.getPost(id);
    }
    
    @DeleteMapping("/posts/{id}")
    @RequiresPermission("DELETE_POST")
    public void deletePost(@PathVariable String id) {
        postService.delete(id);
    }
}
```

**RBAC Architecture:**

```html
User: john@example.com
  │
  ├─ Role: EDITOR
  │    ├─ Permission: READ_POST
  │    ├─ Permission: WRITE_POST
  │    └─ Permission: EDIT_POST
  │
  └─ Role: VIEWER
       └─ Permission: READ_POST

Check: Can John DELETE_POST?
→ Check EDITOR permissions → No DELETE_POST
→ Check VIEWER permissions → No DELETE_POST
→ Result: DENIED
```

### Pattern 2: ABAC (Attribute-Based Access Control)

ABAC is more flexible. Decisions based on attributes of user, resource, and context.

```html
public class ABACPolicy {
    public boolean evaluate(User user, Resource resource, String action, Context context) {
        // Rule: Users can only edit their own posts
        if (action.equals("EDIT") && resource.getType().equals("POST")) {
            return resource.getOwnerId().equals(user.getId());
        }
        
        // Rule: Admins can do anything
        if (user.hasRole("ADMIN")) {
            return true;
        }
        
        // Rule: Users can only delete posts within 24 hours of creation
        if (action.equals("DELETE") && resource.getType().equals("POST")) {
            Post post = (Post) resource;
            long hoursSinceCreation = Duration.between(
                post.getCreatedAt(), 
                context.getCurrentTime()
            ).toHours();
            
            return post.getOwnerId().equals(user.getId()) 
                && hoursSinceCreation < 24;
        }
        
        return false;
    }
}

// Advanced ABAC with policy engine
@Service
public class PolicyEngine {
    public boolean authorize(AuthorizationRequest request) {
        // Collect attributes
        Map<String, Object> attributes = new HashMap<>();
        attributes.put("user.role", request.getUser().getRole());
        attributes.put("user.department", request.getUser().getDepartment());
        attributes.put("resource.type", request.getResource().getType());
        attributes.put("resource.classification", request.getResource().getClassification());
        attributes.put("context.time", LocalTime.now());
        attributes.put("context.location", request.getContext().getLocation());
        
        // Evaluate policy rules
        return policyRepository.getPolicies().stream()
            .anyMatch(policy -> policy.matches(attributes, request.getAction()));
    }
}
```

**Example ABAC Rules:**

```html
Rule 1: Users can view documents if:
  - user.department == document.department
  - OR user.role == "MANAGER"
  - AND context.time BETWEEN 9:00 AND 17:00

Rule 2: Users can delete records if:
  - user.id == record.owner
  - AND record.age < 24 hours
  - AND user.location == "office"
```

### Secure Communication Patterns

### Pattern 1: TLS/HTTPS Everywhere

```html
// Spring Boot - Force HTTPS
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .requiresChannel()
            .anyRequest()
            .requiresSecure(); // Force HTTPS
    }
}
```

### Pattern 2: API Key Management

```html
@Component
public class APIKeyFilter extends OncePerRequestFilter {
    @Autowired
    private APIKeyService apiKeyService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain filterChain) {
        String apiKey = request.getHeader("X-API-Key");
        
        if (apiKey == null) {
            response.setStatus(401);
            return;
        }
        
        // Validate and rate limit
        APIKeyInfo keyInfo = apiKeyService.validate(apiKey);
        if (!keyInfo.isValid() || keyInfo.isRateLimited()) {
            response.setStatus(429); // Too Many Requests
            return;
        }
        
        filterChain.doFilter(request, response);
    }
}
```

### Pattern 3: Request Signing (Preventing Tampering)

```html
@Service
public class RequestSignatureService {
    public String signRequest(String method, String path, String body, String timestamp) {
        String message = method + path + body + timestamp;
        
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secretKey.getBytes(), "HmacSHA256"));
        byte[] signature = mac.doFinal(message.getBytes());
        
        return Base64.getEncoder().encodeToString(signature);
    }
    
    public boolean verifySignature(HttpServletRequest request, String providedSignature) {
        String timestamp = request.getHeader("X-Timestamp");
        
        // Prevent replay attacks - reject old requests
        if (System.currentTimeMillis() - Long.parseLong(timestamp) > 300000) {
            return false; // Older than 5 minutes
        }
        
        String expectedSignature = signRequest(
            request.getMethod(),
            request.getRequestURI(),
            getRequestBody(request),
            timestamp
        );
        
        return MessageDigest.isEqual(
            expectedSignature.getBytes(),
            providedSignature.getBytes()
        );
    }
}
```

### Real-World Security Checklist

**Authentication:**

- Use bcrypt/scrypt for password hashing (never MD5/SHA1)
- Implement account lockout after failed attempts
- Use refresh tokens with JWT
- Implement logout (JWT blacklist for critical apps)

**Authorization:**

- Check permissions on EVERY request (never trust client)
- Use least privilege principle
- Implement resource-level authorization
- Log all authorization failures

**Communication:**

- HTTPS only in production
- Validate ALL inputs (SQL injection, XSS)
- Use CORS properly
- Implement rate limiting
- Set secure cookie flags (HttpOnly, Secure, SameSite)

**Data Protection:**

- Encrypt sensitive data at rest
- Never log passwords or tokens
- Use environment variables for secrets
- Implement audit logging

### Tomorrow: Performance Optimization Patterns

We’ll explore lazy loading, pagination, and connection pooling making systems fast while keeping them secure.

**Remember:** Security is not optional. It’s not a feature. It’s the price of doing business in 2025. One breach can destroy everything you’ve built.

## Previous Articles in This Series

- [Day 1: Building Your Architect Mindset](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [Day 2: Strategy & Observer Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [Day 3: Decorator & Proxy Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [Day 4: Singleton & Builder Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [Day 5: Command & Template Method Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [Day 6: Adapter & Facade Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [Day 7: Chain of Responsibility & State Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [Day 9: Database Patterns & Repository](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [Day 10: Caching Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [Day 11: API Gateway & Proxy Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [Day 12: Message Queue Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [Day 13: Event Sourcing & CQRS](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)
- [Day 14: Monitoring & Observer Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)
- [Day 15: Microservices Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)
- [Day 16: Distributed System Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-16-distributed-system-patterns-87d47197b01a)
- [Day 17: Resilience Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-17-resilience-patterns-66cdacce397e)
- [Day 18: Caching & CDN Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-18-caching-cdn-patterns-58e21237a7e9)
- [Day 19: Database Scaling Patterns](https://archive.is/o/mxIBa/https://medium.com/@kanishks772/learn-system-design-with-me-day-19-database-scaling-patterns-e2d03daf0250)

*Stay secure, stay vigilant. See you tomorrow!*

[0%](https://archive.is/mxIBa#0%) [10%](https://archive.is/mxIBa#10%) [20%](https://archive.is/mxIBa#20%) [30%](https://archive.is/mxIBa#30%) [40%](https://archive.is/mxIBa#40%) [50%](https://archive.is/mxIBa#50%) [60%](https://archive.is/mxIBa#60%) [70%](https://archive.is/mxIBa#70%) [80%](https://archive.is/mxIBa#80%) [90%](https://archive.is/mxIBa#90%) [100%](https://archive.is/mxIBa#100%)