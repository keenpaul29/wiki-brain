---
title: "Learn System Design With Me . Day 5: Command & Template Method Patterns | by The Latency Gambler"
source: "https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c"
author:
  - "[[The Latency Gambler]]"
published:
created: 2026-05-26
description: "Operations as Objects & Algorithmic Frameworks"
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/0*NG5PyO0Bck13bBHQ)

## Learn System Design With Me. Day 5: Command & Template Method Patterns

## Operations as Objects & Algorithmic Frameworks

a11y-light · September 17, 2025 (Updated: September 17, 2025) · Free: No

*This is Day 5 of our 30-day journey from code writer to system architect. Start with* *[Day 1](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)* *to build the foundation, then progress through* *[Day 2](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)**,* *[Day 3](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)**, and* *[Day 4](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*

We've mastered behavioral, structural, and creational patterns. Today, we dive into two patterns that **transform how you think about operations and algorithms**: Command and Template Method.

![None](https://miro.medium.com/v2/resize:fit:700/0*NG5PyO0Bck13bBHQ)

Here's the architect's insight: **Command turns operations into first-class objects you can queue, log, undo, and distribute. Template Method creates algorithmic frameworks that let you change behavior without changing structure.**

These aren't just patterns, they're the backbone of enterprise systems, message queues, and processing pipelines.

#### Command Pattern: Operations as First-Class Citizens

#### The Problem It Solves

Traditional approach: Call methods directly. **Architect approach**: Turn operations into objects you can manipulate queue them, retry them, undo them, audit them.

> Think of every button click, API call, or database operation as a **command object** that can be scheduled, replayed, or rolled back.

#### Basic Command Implementation

```java
// Command Interface - Your Operation Contract
public interface Command {
    void execute();
    void undo(); // Optional but powerful
}

// Receiver - The object that does the actual work
public class BankAccount {
    private String accountId;
    private BigDecimal balance;
    
    public void deposit(BigDecimal amount) {
        balance = balance.add(amount);
        log.info("Deposited {} to account {}. New balance: {}", 
                 amount, accountId, balance);
    }
    
    public void withdraw(BigDecimal amount) {
        if (balance.compareTo(amount) >= 0) {
            balance = balance.subtract(amount);
            log.info("Withdrew {} from account {}. New balance: {}", 
                     amount, accountId, balance);
        } else {
            throw new InsufficientFundsException();
        }
    }
    
    public BigDecimal getBalance() { return balance; }
}

// Concrete Commands - Encapsulated Operations
public class DepositCommand implements Command {
    private final BankAccount account;
    private final BigDecimal amount;
    
    public DepositCommand(BankAccount account, BigDecimal amount) {
        this.account = account;
        this.amount = amount;
    }
    
    @Override
    public void execute() {
        account.deposit(amount);
    }
    
    @Override
    public void undo() {
        account.withdraw(amount); // Reverse the operation
    }
}

public class WithdrawCommand implements Command {
    private final BankAccount account;
    private final BigDecimal amount;
    
    public WithdrawCommand(BankAccount account, BigDecimal amount) {
        this.account = account;
        this.amount = amount;
    }
    
    @Override
    public void execute() {
        account.withdraw(amount);
    }
    
    @Override
    public void undo() {
        account.deposit(amount); // Reverse the operation
    }
}

// Invoker - Manages and executes commands
public class BankingSystem {
    private final Stack<Command> commandHistory = new Stack<>();
    
    public void executeCommand(Command command) {
        try {
            command.execute();
            commandHistory.push(command); // For undo functionality
        } catch (Exception e) {
            log.error("Command execution failed: {}", e.getMessage());
            throw e;
        }
    }
    
    public void undoLastCommand() {
        if (!commandHistory.isEmpty()) {
            Command lastCommand = commandHistory.pop();
            lastCommand.undo();
        }
    }
}
```

#### System Architecture: Command in Action

```
[Client] → [Banking System] → [Command Queue] → [Command Processor] → [Bank Account]
                                     ↓
                               [Audit Log & History]
```

#### Advanced Command: Async Processing with Queues

```java
// Async Command with CompletableFuture
public interface AsyncCommand extends Command {
    CompletableFuture<Void> executeAsync();
}

public class TransferCommand implements AsyncCommand {
    private final BankAccount fromAccount;
    private final BankAccount toAccount;
    private final BigDecimal amount;
    private final String transactionId;
    
    @Override
    public CompletableFuture<Void> executeAsync() {
        return CompletableFuture.runAsync(() -> {
            // Two-phase commit for distributed transactions
            TransactionManager.begin(transactionId);
            try {
                fromAccount.withdraw(amount);
                toAccount.deposit(amount);
                TransactionManager.commit(transactionId);
                
                // Publish event for audit
                eventPublisher.publish(new TransferCompletedEvent(
                    fromAccount.getId(), toAccount.getId(), amount));
                    
            } catch (Exception e) {
                TransactionManager.rollback(transactionId);
                throw new TransferFailedException(e);
            }
        });
    }
    
    @Override
    public void execute() {
        executeAsync().join(); // Blocking version
    }
}

// Command Queue Processor
@Component
public class CommandProcessor {
    private final BlockingQueue<Command> commandQueue = new LinkedBlockingQueue<>();
    private final ExecutorService executorService = Executors.newFixedThreadPool(10);
    
    @PostConstruct
    public void startProcessing() {
        for (int i = 0; i < 10; i++) {
            executorService.submit(() -> {
                while (!Thread.currentThread().isInterrupted()) {
                    try {
                        Command command = commandQueue.take();
                        processCommand(command);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }
            });
        }
    }
    
    public void submitCommand(Command command) {
        commandQueue.offer(command);
    }
    
    private void processCommand(Command command) {
        try {
            if (command instanceof AsyncCommand) {
                ((AsyncCommand) command).executeAsync()
                    .exceptionally(throwable -> {
                        log.error("Async command failed", throwable);
                        return null;
                    });
            } else {
                command.execute();
            }
        } catch (Exception e) {
            log.error("Command execution failed", e);
            // Dead letter queue for failed commands
            deadLetterQueue.add(command);
        }
    }
}
```

#### Command Pattern: Macro Commands & Composite

```java
// Composite Command - Execute multiple commands as one
public class MacroCommand implements Command {
    private final List<Command> commands;
    
    public MacroCommand(List<Command> commands) {
        this.commands = new ArrayList<>(commands);
    }
    
    @Override
    public void execute() {
        for (Command command : commands) {
            command.execute();
        }
    }
    
    @Override
    public void undo() {
        // Undo in reverse order
        for (int i = commands.size() - 1; i >= 0; i--) {
            commands.get(i).undo();
        }
    }
}

// Usage - Complex business operations
public class PayrollProcessor {
    public void processPayroll(List<Employee> employees) {
        List<Command> payrollCommands = employees.stream()
            .map(employee -> new PaySalaryCommand(employee))
            .collect(Collectors.toList());
            
        MacroCommand payrollMacro = new MacroCommand(payrollCommands);
        
        try {
            payrollMacro.execute();
        } catch (Exception e) {
            // If any payment fails, undo all
            payrollMacro.undo();
            throw new PayrollProcessingException(e);
        }
    }
}
```

#### Command in Event Sourcing

```java
// Event Sourcing with Commands
public abstract class DomainCommand implements Command {
    protected final String aggregateId;
    protected final LocalDateTime timestamp;
    
    public abstract List<DomainEvent> execute(AggregateRoot aggregate);
}

public class CreateOrderCommand extends DomainCommand {
    private final String customerId;
    private final List<OrderItem> items;
    
    @Override
    public List<DomainEvent> execute(AggregateRoot aggregate) {
        Order order = (Order) aggregate;
        
        // Business logic
        order.validateCustomer(customerId);
        order.validateItems(items);
        
        // Return events instead of changing state directly
        return List.of(
            new OrderCreatedEvent(aggregateId, customerId, items, timestamp),
            new InventoryReservedEvent(items, timestamp)
        );
    }
}

// Event Store processes commands
@Service
public class OrderCommandHandler {
    public void handle(CreateOrderCommand command) {
        // Load aggregate
        Order order = eventStore.loadAggregate(command.getAggregateId());
        
        // Execute command to get events
        List<DomainEvent> events = command.execute(order);
        
        // Store events
        eventStore.saveEvents(command.getAggregateId(), events);
        
        // Publish events
        events.forEach(eventPublisher::publish);
    }
}
```

#### Template Method Pattern: Algorithmic Frameworks

#### The Problem It Solves

You have algorithms with the same structure but different implementations of specific steps. **Template Method defines the skeleton, subclasses fill in the details.**

#### Basic Template Method Implementation

```java
// Abstract Template Class
public abstract class DataProcessor {
    
    // Template Method - defines the algorithm structure
    public final ProcessResult processData(String inputPath) {
        try {
            // Step 1: Load data
            RawData data = loadData(inputPath);
            
            // Step 2: Validate (hook method - optional)
            if (shouldValidate()) {
                validateData(data);
            }
            
            // Step 3: Transform data
            TransformedData transformed = transformData(data);
            
            // Step 4: Save results
            String outputPath = saveData(transformed);
            
            // Step 5: Cleanup (hook method)
            cleanup(inputPath, outputPath);
            
            return new ProcessResult(outputPath, transformed.getRecordCount());
            
        } catch (Exception e) {
            handleError(e);
            throw new DataProcessingException(e);
        }
    }
    
    // Abstract methods - must be implemented by subclasses
    protected abstract RawData loadData(String inputPath);
    protected abstract TransformedData transformData(RawData data);
    protected abstract String saveData(TransformedData data);
    
    // Hook methods - optional implementations
    protected boolean shouldValidate() { return true; }
    protected void validateData(RawData data) { /* Default: no validation */ }
    protected void cleanup(String inputPath, String outputPath) { /* Default: no cleanup */ }
    protected void handleError(Exception e) { log.error("Processing failed", e); }
}

// Concrete Implementation - CSV Processing
public class CsvDataProcessor extends DataProcessor {
    
    @Override
    protected RawData loadData(String inputPath) {
        try (BufferedReader reader = Files.newBufferedReader(Paths.get(inputPath))) {
            List<String[]> records = new ArrayList<>();
            String line;
            
            while ((line = reader.readLine()) != null) {
                records.add(line.split(","));
            }
            
            return new CsvRawData(records);
        } catch (IOException e) {
            throw new DataLoadException("Failed to load CSV file: " + inputPath, e);
        }
    }
    
    @Override
    protected TransformedData transformData(RawData data) {
        CsvRawData csvData = (CsvRawData) data;
        List<Customer> customers = new ArrayList<>();
        
        for (String[] record : csvData.getRecords()) {
            // Skip header row
            if (record[0].equals("id")) continue;
            
            Customer customer = Customer.builder()
                .id(record[0])
                .name(record[1])
                .email(record[2])
                .registrationDate(parseDate(record[3]))
                .build();
                
            customers.add(customer);
        }
        
        return new CustomerTransformedData(customers);
    }
    
    @Override
    protected String saveData(TransformedData data) {
        CustomerTransformedData customerData = (CustomerTransformedData) data;
        String outputPath = "processed_customers_" + System.currentTimeMillis() + ".json";
        
        try (FileWriter writer = new FileWriter(outputPath)) {
            ObjectMapper mapper = new ObjectMapper();
            mapper.writeValue(writer, customerData.getCustomers());
            return outputPath;
        } catch (IOException e) {
            throw new DataSaveException("Failed to save processed data", e);
        }
    }
    
    @Override
    protected void validateData(RawData data) {
        CsvRawData csvData = (CsvRawData) data;
        
        if (csvData.getRecords().isEmpty()) {
            throw new DataValidationException("CSV file is empty");
        }
        
        // Validate header
        String[] header = csvData.getRecords().get(0);
        if (!Arrays.equals(header, new String[]{"id", "name", "email", "date"})) {
            throw new DataValidationException("Invalid CSV header format");
        }
    }
}
// Alternative Implementation - JSON Processing
public class JsonDataProcessor extends DataProcessor {
    
    @Override
    protected RawData loadData(String inputPath) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode jsonArray = mapper.readTree(new File(inputPath));
            return new JsonRawData(jsonArray);
        } catch (IOException e) {
            throw new DataLoadException("Failed to load JSON file: " + inputPath, e);
        }
    }
    
    @Override
    protected TransformedData transformData(RawData data) {
        JsonRawData jsonData = (JsonRawData) data;
        List<Customer> customers = new ArrayList<>();
        
        for (JsonNode node : jsonData.getJsonArray()) {
            Customer customer = Customer.builder()
                .id(node.get("customer_id").asText())
                .name(node.get("full_name").asText())
                .email(node.get("email_address").asText())
                .registrationDate(parseDate(node.get("signup_date").asText()))
                .build();
                
            customers.add(customer);
        }
        
        return new CustomerTransformedData(customers);
    }
    
    @Override
    protected String saveData(TransformedData data) {
        // Same as CSV processor - saves as JSON
        return super.saveData(data);
    }
    
    @Override
    protected boolean shouldValidate() {
        return false; // JSON is self-validating
    }
}
```

#### System Architecture: Processing Pipeline

```
[Data Source] → [Template Method Framework] → [Output Store]
                         ↓
                [Load] → [Validate] → [Transform] → [Save] → [Cleanup]
                  ↓         ↓           ↓          ↓         ↓
               [Impl]   [Hook]      [Impl]     [Impl]   [Hook]
```

#### Advanced Template Method: Spring Framework Integration

```java
// Spring's Template Method Implementation
@Component
public abstract class TransactionalDataProcessor extends DataProcessor {
    
    @Autowired
    protected TransactionTemplate transactionTemplate;
    
    @Override
    public final ProcessResult processData(String inputPath) {
        return transactionTemplate.execute(status -> {
            try {
                return super.processData(inputPath);
            } catch (Exception e) {
                status.setRollbackOnly();
                throw e;
            }
        });
    }
    
    // Template method for batch processing
    protected final void processBatch(List<Customer> customers) {
        int batchSize = getBatchSize();
        
        for (int i = 0; i < customers.size(); i += batchSize) {
            List<Customer> batch = customers.subList(
                i, Math.min(i + batchSize, customers.size()));
                
            processBatchInternal(batch);
            
            // Hook for progress reporting
            onBatchProcessed(i / batchSize + 1, 
                           (customers.size() + batchSize - 1) / batchSize);
        }
    }
    
    protected abstract void processBatchInternal(List<Customer> batch);
    protected abstract int getBatchSize();
    
    // Hook method
    protected void onBatchProcessed(int currentBatch, int totalBatches) {
        log.info("Processed batch {}/{}", currentBatch, totalBatches);
    }
}

// Concrete implementation with database operations
@Service
public class DatabaseCustomerProcessor extends TransactionalDataProcessor {
    
    @Autowired
    private CustomerRepository customerRepository;
    
    @Override
    protected void processBatchInternal(List<Customer> batch) {
        customerRepository.saveAll(batch);
    }
    
    @Override
    protected int getBatchSize() {
        return 1000; // Process 1000 customers at a time
    }
    
    @Override
    protected void onBatchProcessed(int currentBatch, int totalBatches) {
        super.onBatchProcessed(currentBatch, totalBatches);
        
        // Custom progress reporting
        progressService.updateProgress(
            (double) currentBatch / totalBatches * 100
        );
    }
}
```

#### Template Method with Strategy Pattern Combination

```typescript
// Combining Template Method + Strategy for ultimate flexibility
public abstract class ConfigurableDataProcessor extends DataProcessor {
    
    protected DataValidator validator;
    protected DataTransformer transformer;
    protected DataSaver saver;
    
    public ConfigurableDataProcessor(DataValidator validator, 
                                   DataTransformer transformer, 
                                   DataSaver saver) {
        this.validator = validator;
        this.transformer = transformer;
        this.saver = saver;
    }
    
    @Override
    protected final TransformedData transformData(RawData data) {
        // Template method delegates to strategy
        return transformer.transform(data);
    }
    
    @Override
    protected final void validateData(RawData data) {
        validator.validate(data);
    }
    
    @Override
    protected final String saveData(TransformedData data) {
        return saver.save(data);
    }
    
    // Factory method for creating processors
    public static DataProcessor createProcessor(String type) {
        return switch (type.toLowerCase()) {
            case "csv" -> new CsvConfigurableProcessor(
                new CsvValidator(), 
                new CustomerTransformer(), 
                new JsonSaver()
            );
            case "xml" -> new XmlConfigurableProcessor(
                new XmlValidator(), 
                new CustomerTransformer(), 
                new DatabaseSaver()
            );
            default -> throw new IllegalArgumentException("Unknown processor type: " + type);
        };
    }
}
```

#### Combining Command + Template Method: Enterprise Pipeline

```java
// Command that uses Template Method for processing
public class ProcessDataCommand implements AsyncCommand {
    private final String inputPath;
    private final DataProcessor processor;
    private final String commandId;
    
    @Override
    public CompletableFuture<Void> executeAsync() {
        return CompletableFuture.runAsync(() -> {
            // Template method defines the process
            ProcessResult result = processor.processData(inputPath);
            
            // Command handles the result
            auditService.logProcessingComplete(commandId, result);
            notificationService.notifyComplete(commandId, result);
        });
    }
}

// System orchestration
@Service
public class DataProcessingOrchestrator {
    
    public void scheduleDataProcessing(String inputPath, String processorType) {
        // Template Method pattern for processor selection
        DataProcessor processor = DataProcessorFactory.create(processorType);
        
        // Command pattern for async execution
        ProcessDataCommand command = new ProcessDataCommand(
            inputPath, processor, UUID.randomUUID().toString());
        
        commandProcessor.submitCommand(command);
    }
}
```

#### Anti-Patterns: What Goes Wrong

#### Command Anti-Patterns

#### 1\. Anemic Commands

```typescript
// DON'T DO THIS - Command with no behavior
public class AnémicCommand implements Command {
    private String data;
    
    public void execute() {
        // Does nothing meaningful
    }
}
```

#### 2\. God Commands

```
// DON'T DO THIS - Command that does everything
public class ProcessEverythingCommand implements Command {
    public void execute() {
        // 500 lines of mixed responsibilities
        validateInput();
        processPayment();
        sendEmails();
        updateInventory();
        generateReports();
        cleanupTempFiles();
    }
}
```

#### Template Method Anti-Patterns

#### 1\. Too Many Abstract Methods

```csharp
// DON'T DO THIS - Forces too much implementation
public abstract class OverAbstractedTemplate {
    protected abstract void step1();
    protected abstract void step2();
    protected abstract void step3();
    protected abstract void step4();
    protected abstract void step5();
    // ... 20 more abstract methods
}
```

#### 2\. Non-Final Template Method

```csharp
// DON'T DO THIS - Allows breaking the algorithm
public abstract class BreakableTemplate {
    public void templateMethod() { // Should be final!
        // Subclasses can override and break the flow
    }
}
```

#### Production Lessons: What I Learned

### Command Pattern Lessons

1. **Commands should be serializable**: For persistent queues and distributed processing
2. **Include correlation IDs**: Essential for tracing in microservices
3. **Design for idempotency**: Commands might be executed multiple times
4. **Separate command from query**: Commands change state, queries don't

#### Template Method Lessons

1. **Keep abstract methods minimal**: Too many break the pattern's value
2. **Use hooks for optional behavior**: Better than forcing implementations
3. **Make template method final**: Prevents subclasses from breaking the algorithm
4. **Document the contract**: Clear expectations for implementers

#### Tomorrow's Preview

Day 6: "Adapter & Facade Patterns". How to integrate incompatible systems and simplify complex interfaces. We'll explore how payment gateways use adapters and how microservice facades hide complexity.

#### Your Architect Assignment

Examine your current system:

1. **Find repetitive operations** that could become commands
2. **Identify similar algorithms** with different implementations that need Template Method
3. **Look for undo/redo functionality** that could benefit from command pattern
4. **Spot processing pipelines** that could use template method frameworks

> Remember: **Command makes operations first-class, Template Method makes algorithms extensible. Both are essential for maintainable, scalable systems.**

*Previous articles:*

- *[Day 1 Building Your Architect Mindset](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)*
- *[Day 2 Strategy & Observer Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*
- *[Day 3 Decorator & Proxy Patterns](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*
- *[Day 4 Singleton & Builder Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*

*Follow along daily as we master the behavioral patterns that create flexible, maintainable systems.*

[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c#bypass)