#!/usr/bin/env python3
"""
Recipe Reorganizer
==================

This script reorganizes recipes from the current flat JSON structure
into a hierarchical folder structure organized by brewing method and author.

Structure:
- PerfectBrew/Resources/Recipes/{METHOD}/{AUTHOR}/{SERVINGS}/
  - single_serve.json
  - two_people.json
  - three_people.json
  - four_people.json
"""

import json
import os
import re
from pathlib import Path

def extract_author_from_title(title):
    """Extract author name from recipe title"""
    # V60 authors
    if "James Hoffmann" in title:
        return "James_Hoffmann"
    elif "Kaldi's Coffee" in title:
        return "Kaldis_Coffee"
    elif "Tetsu Kasuya" in title:
        return "Tetsu_Kasuya"
    elif "Scott Rao" in title:
        return "Scott_Rao"
    elif "Quick Morning" in title or "Competition Style" in title or "V60 Family" in title:
        return "Others"
    
    # French Press authors
    elif "Tim Wendelboe" in title:
        return "Tim_Wendelboe"
    elif "Stumptown" in title:
        return "Stumptown"
    elif "Blue Bottle" in title:
        return "Blue_Bottle"
    elif "Intelligentsia" in title:
        return "Intelligentsia"
    elif "Counter Culture" in title:
        return "Counter_Culture"
    elif "Ritual" in title:
        return "Ritual"
    elif "Verve" in title:
        return "Verve"
    elif "Four Barrel" in title:
        return "Four_Barrel"
    
    # Chemex
    elif "Chemex Classic" in title:
        return "Classic"
    
    # AeroPress
    elif "Championship Concentrate" in title:
        return "Champions"
    elif "World AeroPress Champion" in title:
        return "World_Champions"
    
    return "Unknown"

def extract_servings_from_title(title):
    """Extract servings count from recipe title"""
    if "Single Serve" in title or "Single" in title:
        return 1
    elif "Two People" in title or "Two" in title:
        return 2
    elif "Three People" in title or "Three" in title:
        return 3
    elif "Four People" in title or "Four" in title:
        return 4
    else:
        return 1  # Default to single serve

def get_servings_filename(servings):
    """Get filename based on servings count"""
    if servings == 1:
        return "single_serve.json"
    elif servings == 2:
        return "two_people.json"
    elif servings == 3:
        return "three_people.json"
    elif servings == 4:
        return "four_people.json"
    else:
        return f"{servings}_people.json"

def reorganize_recipes():
    """Main function to reorganize all recipes"""
    
    # Define source files and their corresponding methods
    source_files = {
        "recipes_v60.json": "V60",
        "recipes_frenchpress.json": "French_Press", 
        "recipes_chemex.json": "Chemex",
        "recipes_aeropress.json": "AeroPress"
    }
    
    base_path = Path("PerfectBrew/Resources")
    recipes_path = base_path / "Recipes"
    
    # Process each source file
    for filename, method in source_files.items():
        print(f"\nProcessing {filename} -> {method}")
        
        source_file = base_path / filename
        if not source_file.exists():
            print(f"  ❌ Source file not found: {source_file}")
            continue
            
        # Load recipes from source file
        with open(source_file, 'r', encoding='utf-8') as f:
            recipes = json.load(f)
        
        print(f"  📖 Loaded {len(recipes)} recipes")
        
        # Group recipes by author
        recipes_by_author = {}
        for recipe in recipes:
            author = extract_author_from_title(recipe['title'])
            servings = extract_servings_from_title(recipe['title'])
            
            if author not in recipes_by_author:
                recipes_by_author[author] = {}
            if servings not in recipes_by_author[author]:
                recipes_by_author[author][servings] = []
                
            recipes_by_author[author][servings].append(recipe)
        
        # Create directories and save recipes
        for author, servings_dict in recipes_by_author.items():
            author_path = recipes_path / method / author
            author_path.mkdir(parents=True, exist_ok=True)
            
            print(f"  👤 {author}: {len(servings_dict)} serving variants")
            
            for servings, recipes_list in servings_dict.items():
                filename = get_servings_filename(servings)
                output_file = author_path / filename
                
                # Save recipes to file
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(recipes_list, f, indent=2, ensure_ascii=False)
                
                print(f"    💾 {filename}: {len(recipes_list)} recipes")
    
    print(f"\n✅ Recipe reorganization complete!")
    print(f"📁 New structure created in: {recipes_path}")

if __name__ == "__main__":
    reorganize_recipes()
