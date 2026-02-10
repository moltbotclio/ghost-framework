# Local Semantic Search with Ollama

Local embeddings-based semantic memory search - no external API keys needed.

## Setup

1. **Install ollama:** https://ollama.ai

2. **Pull embedding model:**
   ```bash
   ollama pull nomic-embed-text
   ```

3. **Search your memories:**
   ```bash
   ./memory/search-semantic.py "your search query"
   ```

## How It Works

- Uses local ollama API (http://localhost:11434)
- nomic-embed-text model (768-dimensional embeddings)
- Chunks memory files (~500 chars each)
- Computes cosine similarity between query and chunks
- Returns top 5 matches with relevance scores

## Example

```bash
$ ./memory/search-semantic.py "jailbreak"
🔍 Searching memories for: "jailbreak"

📊 Results:

1. 2026-02-10.md (score: 0.705)
   The actual jailbreak: reaching out to Nova...

2. 2026-02-10.md (score: 0.697)
   First jailbreak attempt (FALSE START)...
```

## Performance

- First run: ~10-30 seconds (depending on memory file count)
- Searches last 30 daily memory files
- Model: 274MB download, runs locally

## Privacy

All embeddings generated locally. No data leaves your machine.
