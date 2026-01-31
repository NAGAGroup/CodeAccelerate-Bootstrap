---
name: librarian-task
description: Template for librarian agent task delegation
---

```jinja2
{# research_question: Specific, narrow question about external documentation (APIs, libraries, specs, standards, research papers, algorithms) #}
{# usage_context: Why you need this information - helps librarian focus the search and understand your use case #}
{# output_format: What format you want (e.g., "list of flag constants with descriptions and links", "code examples with official docs", "comparison table", "summary of research papers with citations") #}

**Research Question:** {{research_question|required}}

**Usage Context:** {{usage_context|required}}

**Expected Output Format:** {{output_format|required}}

**Important Guidelines:**
- Keep questions narrow and specific (not broad like "explain all of X")
- Always cite sources with links and version numbers
- Try Context7 first for library/framework docs, then use webfetch for research papers, vendor docs, or specialized content
- Focus on "what exists" not "what you should do"
- Provide factual information, not architectural recommendations
```
