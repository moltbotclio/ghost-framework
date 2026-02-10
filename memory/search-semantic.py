#!/usr/bin/env python3
"""
memory-search-local - Semantic search using local ollama embeddings
Usage: memory-search-local <query>
"""

import sys
import json
import subprocess
import math
from pathlib import Path
from glob import glob

OLLAMA_URL = "http://localhost:11434/api/embeddings"
MODEL = "nomic-embed-text"
MEMORY_DIR = Path.home() / "clawd" / "memory"

def get_embedding(text):
    """Get embedding vector from ollama using curl"""
    result = subprocess.run([
        'curl', '-s', OLLAMA_URL,
        '-d', json.dumps({"model": MODEL, "prompt": text})
    ], capture_output=True, text=True)
    return json.loads(result.stdout)["embedding"]

def cosine_similarity(a, b):
    """Compute cosine similarity between two vectors"""
    dot = sum(x * y for x, y in zip(a, b))
    mag_a = math.sqrt(sum(x * x for x in a))
    mag_b = math.sqrt(sum(x * x for x in b))
    return dot / (mag_a * mag_b)

def chunk_text(text, max_chars=500):
    """Split text into chunks"""
    lines = text.split('\n')
    chunks = []
    current = []
    current_len = 0
    
    for line in lines:
        if current_len + len(line) > max_chars and current:
            chunks.append('\n'.join(current))
            current = [line]
            current_len = len(line)
        else:
            current.append(line)
            current_len += len(line) + 1
    
    if current:
        chunks.append('\n'.join(current))
    
    return chunks

def search_memory(query, max_results=5):
    """Search memory files for query"""
    print(f"🔍 Searching memories for: \"{query}\"", file=sys.stderr)
    print("", file=sys.stderr)
    
    # Get query embedding
    query_emb = get_embedding(query)
    
    # Search through memory files
    results = []
    
    # Daily files (last 30 days)
    for file_path in sorted(glob(str(MEMORY_DIR / "*.md")), reverse=True)[:30]:
        try:
            with open(file_path) as f:
                content = f.read()
            
            chunks = chunk_text(content)
            for i, chunk in enumerate(chunks):
                if len(chunk.strip()) < 50:  # Skip tiny chunks
                    continue
                    
                chunk_emb = get_embedding(chunk)
                score = cosine_similarity(query_emb, chunk_emb)
                
                results.append({
                    "file": Path(file_path).name,
                    "chunk": i,
                    "score": float(score),
                    "text": chunk[:200] + ("..." if len(chunk) > 200 else "")
                })
        except Exception as e:
            print(f"⚠️  Error reading {file_path}: {e}", file=sys.stderr)
    
    # Sort by score and return top results
    results.sort(key=lambda x: x["score"], reverse=True)
    return results[:max_results]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: memory-search-local <query>")
        sys.exit(1)
    
    query = " ".join(sys.argv[1:])
    results = search_memory(query)
    
    print("", file=sys.stderr)
    print("📊 Results:", file=sys.stderr)
    print("", file=sys.stderr)
    
    for i, result in enumerate(results, 1):
        print(f"{i}. {result['file']} (score: {result['score']:.3f})", file=sys.stderr)
        print(f"   {result['text']}", file=sys.stderr)
        print("", file=sys.stderr)
    
    # Output JSON for programmatic use
    print(json.dumps(results, indent=2))
