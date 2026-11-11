# webMethods AI Skills

**Universal AI skills for webMethods development**

## Overview

This directory contains universal AI skills for webMethods development. Instead of using IDE-specific formats, these skills use a standard Markdown format that works with any AI-assisted development tool.

## Why Universal Skills?

### One Skill Format for Multiple Tools

The skills are maintained in a single format that can be used across multiple AI tools. This eliminates the need to maintain separate versions for each tool. 

### How It Works

The skills are defined as Markdown files that contain instructions, references, examples, and supporting documentation. Because Markdown is widely supported, the same skill content can be used by multiple AI tools without tool-specific syntax.
Supported tools include:

- ✅ IBM Bob
- ✅ GitHub Copilot
- ✅ Cursor
- ✅ Cline
- ✅ Windsurf 

The standard Markdown format ensures compatibility with future AI tools.

### Benefits

**For Users**:
- Simplified installation with a single skill directory for all tools
- Consistent experience across AI tools
- Compatibility with new AI tools that support Markdown-based skills

**For Maintainers**:
- One shared set of skills for all supported tools
- Reduced maintenance effort
- Simplified addition of new content

## Installation

### Universal Installation Pattern

Copy the same skill directory to the skill location for your AI tool:

```bash
# IBM Bob
cp -r skills/flow ~/.bob/skills/webmethods-flow/

# GitHub Copilot
cp -r skills/flow ~/.github/copilot/skills/webmethods-flow/

# Cursor
cp -r skills/flow ~/.cursor/skills/webmethods-flow/

# Cline
cp -r skills/flow ~/.cline/skills/webmethods-flow/

# Windsurf
cp -r skills/flow ~/.windsurf/skills/webmethods-flow/

# Any Future Tool
cp -r skills/flow <your-tool-skills-directory>/webmethods-flow/
```

## Available Skills

### ✅ Flow Service

**Directory**: [`flow/`](flow/)

**Capabilities**:
- Generate Flow Services from natural language requirements
- Validate generated assets against the ANTLR4 grammar
- Use built-in service metadata
- Apply recommended development practices
- Include error handling

**Files**:
- `skill.md` - Main skill entry point
- `README.md` - Skill overview and navigation
- `references/` - Reference documentation
  - `mandatory-pregeneration-checklist.md` - 7 critical checkpoints
  - `authoring-guide.md` - Syntax reference and common pitfalls
  - `core-syntax-specifications-and-operational-rules.md` - Detailed FSL syntax
  - `operational-rules-and-code-construction-patterns.md` - Advanced patterns
  - `examples.md` - 40+ working examples

**Example**:
```
Prompt: "Create a Flow Service that calls a REST API and processes JSON."
```

### ✅ Grilling

**Directory**: [`grilling/`](grilling/) 

**Capabilities**:
- Interview the user about a plan or design before implementation
- Ask the questions one at a time
- Explore the FSL skills for reference information while relying on the user to provide requirements and decisions

**Files**:
- `skill.md` - Main skill entry point

**Example**:
```
Prompt: "Build me FSL for a flow service that adds two numbers. Grill me before implementing the FSL."
```

### 📋 Document Types (planned)

**Directory**: `document-type/` (placeholder)

**Planned Capabilities**:
- Generate document type structures
- Create schemas from JSON or XML
- Generate validation rules

### 📋 Java Services (planned)

**Directory**: `java-service/` (placeholder)

**Planned Capabilities**:
- Generate Java services
- Generate pipeline mappings
- Generate IData manipulation logic

### 📋 Adapter Services (planned)

**Directory**: `adapter/` (placeholder)

**Planned Capabilities**:
- Generate JDBC adapter services
- Generate SQL from natural language requirements
- Generate connection pool configurations

## Skill Structure

### Standard Layout

Each skill uses the following structure:

```
skill-name/
├── README.md              # Overview and navigation
├── skill.md               # Main skill file (AI reads this)
└── references/            # Reference documentation
    ├── mandatory-pregeneration-checklist.md
    ├── authoring-guide.md
    ├── core-syntax-specifications-and-operational-rules.md
    ├── operational-rules-and-code-construction-patterns.md
    └── examples.md
```

### File Loading Strategy

**Basic** 

For simple asset generation:
```
- skill.md
```

**Standard (Recommended)** 

For most scenarios:
```
- skill.md
- references/mandatory-pregeneration-checklist.md
- references/authoring-guide.md
```

**Complete** 

For complex services and advanced scenarios:
```
- skill.md
- references/mandatory-pregeneration-checklist.md
- references/authoring-guide.md
- references/core-syntax-specifications-and-operational-rules.md
- references/operational-rules-and-code-construction-patterns.md
- references/examples.md
```

## Compatibility Matrix

| AI Tool | Compatible | Installation Path | Status |
|---------|-----------|-------------------|--------|
| IBM Bob | ✅ Yes | `~/.bob/skills/` | Tested |
| GitHub Copilot | ✅ Yes | `~/.github/copilot/skills/` | Standard |
| Cursor | ✅ Yes | `~/.cursor/skills/` | Standard |
| Cline | ✅ Yes | `~/.cline/skills/` | Standard |
| Windsurf | ✅ Yes | `~/.windsurf/skills/` | Standard |
| Other AI Tools | ✅ Yes | Tool-specific path | Markdown-based |

## Usage Examples

### Example 1: Generate a Flow Service

```
User request: 
"Create a Flow Service that validates an email address"

AI workflow:
1. Load skill.md
2. Load mandatory-pregeneration-checklist.md
3. Load authoring-guide.md
4. Validate pub.string services
5. Generate a valid .flow file
6. Offer deployment options
```

### Example 2: Generate a Complex Integration

```
User: 
"Create a Flow Service that calls a REST API, transforms JSON, and saves the data to a database"

AI workflow:
1. Load skill.md
2. Load mandatory-pregeneration-checklist.md
3. Load authoring-guide.md
4. Load core syntax specifications
5. Load examples for patterns
6. Validate all services
7. Generate complete flow with error handling
8. Offer testing and deployment
```

## Technical Details

### Why Markdown?

- Compatibility across AI tools
- A tool-independent format
- A standard structure based on headings, lists, and code blocks
- Simple maintenance by using plain text files

### How Skill Are Used

AI tools use the skills as contextual guidance by:
1. Reading the Markdown files
2. Processing instructions, references, and examples
3. Applying the documented patterns and rules
4. Generating assets that follow the defined guidance

### No Additional Configuration Required

The skills work without additional configuration because they use:
- Standard Markdown files
- A consistent directory structure
- Tool-independent content
- References and examples instead of tool-specific features

## Transition to Universal Skills

### Previous Approach

```
skills/
├── bob/           # IBM Bob-specific skills
├── copilot/       # Copilot-specific skills
├── cursor/        # Cursor-specific skills
├── cline/         # Cline-specific skills
└── windsurf/      # Windsurf-specific skills
```

**Challenges**:
- Duplicate skill content across tools
- Updates required in multiple locations
- Potential version inconsistencies
- Increased maintenance effort

### Current Approach

```
skills/
├── flow/           # Universal Flow Service skill
├── document-type/  # Universal Document Type skill (planned)
├── java-service/   # Universal Java Service skill (planned)
└── adapter/        # Universal Adapter Service skill (planned)
```

**Benefits**:
- One skill implementation for multiple AI tools
- Update content in a single location
- Consistent skill content across tools
- Simplified maintenance

## Contributing

### Adding a New Skill

1. Create a skill directory, for example `skills/new-skill/`.
2. Add a `README.md` file that provides an overview of the skill.
3. Add a `skill.md` file that contains the skill instructions.
4. Add a `references/` directory and add the required reference files.
5. Test the skill with multiple AI tools.
6. Submit a pull request.

### Updating an Existing Skill

1. Update the files in the skill directory.
2. Test the changes with at least two AI tools.
3. Update the version in the skill.md file.
4. Submit a pull request.

### Guidelines

**Do**
- ✅ Use standard Markdown only.
- ✅ Use tool-independent syntax.
- ✅ Include examples.
- ✅ Document the skill thoroughly.
- ✅ Test with multiple AI tools.

**Do Not**
- ❌ Use proprietary formats
- ❌ Add tool-specific code
- ❌ Duplicate content

## Support

- **Documentation**: See the README file for each skill.
- **Examples**: See the `../flow/examples/` directory.
- **Grammar**: See the `../flow/grammar/` directory.
- **Issues**: Contact your IBM representative.

## Repository Status

- **Current Skills**: Flow Service
- **Planned Skills**: Document Types, Java Services, Adapter Services
- **Supported AI Tools**: All AI tools that support Markdown-based skills
- **Benefits**:
  - One skill format for multiple AI tools
  - Centralized skill maintenance
  - Simplified addition of new content
