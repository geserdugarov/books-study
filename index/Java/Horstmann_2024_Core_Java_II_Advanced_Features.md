# Core Java, Volume II — Advanced Features (Thirteenth Edition)

## Book Metadata
- **Title:** Core Java, Volume II — Advanced Features
- **Author:** Cay S. Horstmann
- **Publisher:** Pearson (Oracle Press)
- **Year:** 2024 (Thirteenth Edition)
- **ISBN:** 978-0-13-537174-9
- **Java Version:** Java 21

## Target Audience and Prerequisites
- Programmers who want to put Java technology to work in real projects
- Requires familiarity with Java fundamentals (Volume I or equivalent)
- Covers advanced topics that a professional Java programmer needs to know
- Chapters are largely independent — can be read in any order

## Overall Focus
The second volume of Core Java, covering the advanced libraries and APIs that professional Java developers need. Spans the Streams API, I/O, XML, networking, databases, internationalization, security, GUI programming (Swing/AWT), and native methods. Updated for Java 21 with emphasis on modern APIs.

---

## Table of Contents

### Chapter 1: Streams
- 1.1 From Iterating to Stream Operations
- 1.2 Stream Creation
- 1.3 The filter, map, and flatMap Methods
- 1.4 Extracting Substreams and Combining Streams
- 1.5 Other Stream Transformations
- 1.6 Simple Reductions
- 1.7 The Optional Type
- 1.8 Collecting Results
- 1.9 Collecting into Maps
- 1.10 Grouping and Partitioning
- 1.11 Downstream Collectors
- 1.12 Reduction Operations
- 1.13 Primitive Type Streams
- 1.14 Parallel Streams

**Summary:** The Java Streams API for functional-style data processing. Stream creation, intermediate operations (filter, map, flatMap), terminal operations (reductions, collectors), Optional for null-safe values, collecting into maps with grouping/partitioning, and parallel stream execution for multicore performance.

### Chapter 2: Input and Output
- 2.1 Input/Output Streams
- 2.2 Reading and Writing Binary Data
- 2.3 Object Input/Output Streams and Serialization
- 2.4 Working with Files
- 2.5 Memory-Mapped Files
- 2.6 File Locking
- 2.7 Regular Expressions

**Summary:** Java I/O in depth. Input/output stream hierarchy, binary data handling, object serialization, the NIO.2 file API (Path, Files), memory-mapped files for high-performance I/O, file locking for concurrent access, and regular expressions with the java.util.regex package.

### Chapter 3: XML
- 3.1 Introducing XML
- 3.2 The Structure of an XML Document
- 3.3 Parsing an XML Document
- 3.4 Validating XML Documents
- 3.5 Locating Information with XPath
- 3.6 Using Namespaces
- 3.7 Streaming Parsers
- 3.8 Generating XML Documents
- 3.9 XSL Transformations

**Summary:** XML processing in Java. DOM and SAX parsing, DTD and Schema validation, XPath queries, XML namespaces, StAX streaming parsers, programmatic XML generation, and XSLT transformations.

### Chapter 4: Networking
- 4.1 Connecting to a Server
- 4.2 Implementing Servers
- 4.3 Getting Web Data
- 4.4 The HTTP Client
- 4.5 The Simple HTTP Server
- 4.6 Sending E-Mail

**Summary:** Network programming. Socket connections (client and server), URL handling, the modern java.net.http.HttpClient (Java 11+), the simple HTTP server for testing, and email via the Jakarta Mail API.

### Chapter 5: Database Programming
- 5.1 The Design of JDBC
- 5.2 The Structured Query Language
- 5.3 JDBC Configuration
- 5.4 Working with JDBC Statements
- 5.5 Query Execution
- 5.6 Scrollable and Updatable Result Sets
- 5.7 Row Sets
- 5.8 Metadata
- 5.9 Transactions
- 5.10 Connection Management in Web and Enterprise Applications

**Summary:** Database access via JDBC. SQL basics, JDBC driver configuration, prepared statements, result set navigation (scrollable, updatable), row sets, database metadata inspection, transaction management, and connection pooling for enterprise use.

### Chapter 6: The Date and Time API
- 6.1 The Time Line
- 6.2 Local Dates
- 6.3 Date Adjusters
- 6.4 Local Time
- 6.5 Zoned Time
- 6.6 Formatting and Parsing
- 6.7 Interoperating with Legacy Code

**Summary:** The java.time API (Java 8+). Instants and durations on the time line, LocalDate/LocalTime/LocalDateTime, date adjusters, ZonedDateTime for time zone handling, formatting/parsing with DateTimeFormatter, and bridging to legacy Date/Calendar classes.

### Chapter 7: Internationalization
- 7.1 Locales
- 7.2 Number Formats
- 7.3 Date and Time
- 7.4 Collation and Normalization
- 7.5 Message Formatting
- 7.6 Text Boundaries
- 7.7 Text Input and Output
- 7.8 Resource Bundles
- 7.9 A Complete Example

**Summary:** Building applications for global audiences. Locale management, locale-sensitive number/date/time formatting, string collation and Unicode normalization, message formatting with placeholders, text boundary analysis, character encoding, and resource bundles for localized strings.

### Chapter 8: Compiling and Scripting
- 8.1 The Compiler API
- 8.2 Scripting for the Java Platform

**Summary:** Dynamic code execution. Programmatic compilation using the javax.tools.JavaCompiler API and scripting engine integration for executing code in languages like JavaScript and Groovy from Java programs.

### Chapter 9: Security
- 9.1 Class Loaders
- 9.2 User Authentication
- 9.3 Digital Signatures
- 9.4 Encryption

**Summary:** Java security infrastructure. Class loaders and their hierarchy, user authentication with JAAS (Java Authentication and Authorization Service), digital signatures for code integrity, and encryption with the JCE (Java Cryptography Extension) — AES, RSA algorithms.

### Chapter 10: Graphical User Interface Programming
- 10.1 A History of Java User Interface Toolkits
- 10.2 Displaying Frames
- 10.3 Displaying Information in a Component
- 10.4 Event Handling
- 10.5 The Preferences API

**Summary:** GUI fundamentals. History of Java UI toolkits (AWT, Swing, JavaFX), creating and displaying frames, custom painting in components, the event handling model (listeners, adapters, actions), and the Preferences API for persistent user settings.

### Chapter 11: User Interface Components with Swing
- 11.1 Swing and the Model-View-Controller Design Pattern
- 11.2 Introduction to Layout Management
- 11.3 Text Input
- 11.4 Choice Components
- 11.5 Menus
- 11.6 The Grid Bag Layout
- 11.7 Custom Layout Managers
- 11.8 Dialog Boxes

**Summary:** Swing component library. MVC architecture in Swing, layout managers (FlowLayout, BorderLayout, GridLayout, GridBagLayout), text components, selection components (checkboxes, radio buttons, combo boxes, lists, sliders), menus, custom layouts, and dialog boxes (option panes, file choosers, color choosers).

### Chapter 12: Advanced Swing and Graphics
- 12.1 Tables
- 12.2 Working with Rows and Columns
- 12.3 Cell Rendering and Editing
- 12.4 Trees
- 12.5 Advanced AWT
- 12.6 Raster Images
- 12.7 Printing

**Summary:** Advanced GUI components and graphics. JTable for tabular data (sorting, filtering, custom renderers/editors), JTree for hierarchical data, advanced AWT (shapes, areas, strokes, paint, coordinate transformations, clipping), image manipulation, and printing support.

### Chapter 13: Native Methods
- 13.1 Calling a C Function from a Java Program
- 13.2 Numeric Parameters and Return Values
- 13.3 String Parameters
- 13.4 Accessing Fields
- 13.5 Encoding Signatures
- 13.6 Calling Java Methods
- 13.7 Accessing Array Elements
- 13.8 Handling Errors
- 13.9 Using the Invocation API
- 13.10 A Complete Example: Accessing the Windows Registry
- 13.11 Foreign Functions: A Glimpse into the Future

**Summary:** Java Native Interface (JNI) for calling C/C++ from Java and vice versa. Covers parameter passing (numeric, string, arrays), field and method access across the boundary, error handling, the Invocation API for embedding the JVM, and a preview of the modern Foreign Function & Memory API.

---

## Key Topics and Concepts

### Streams and Functional Programming
- Stream creation, intermediate and terminal operations
- Collectors (grouping, partitioning, downstream)
- Optional type
- Parallel streams

### I/O and Data Processing
- Input/output stream hierarchy
- NIO.2 file API (Path, Files)
- Object serialization
- Memory-mapped files
- Regular expressions

### Data Formats
- XML (DOM, SAX, StAX, XPath, XSLT)
- JDBC (database access, transactions, connection pools)

### Networking
- Sockets (client and server)
- HTTP Client (Java 11+)
- Email protocols

### Date/Time and Internationalization
- java.time API (LocalDate, ZonedDateTime, Duration)
- Locales, number/date formatters
- Resource bundles, collation, Unicode normalization

### Security
- Class loaders
- Authentication (JAAS)
- Digital signatures and encryption (JCE)

### GUI Programming
- Swing (MVC, layout managers, components)
- Event handling model
- Advanced graphics (AWT 2D, images, printing)
- Tables and trees

### Native Interop
- JNI (Java Native Interface)
- Foreign Function & Memory API (preview)
