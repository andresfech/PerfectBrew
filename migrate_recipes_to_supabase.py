import os
import json
import argparse
import sys
from pathlib import Path

# Try to import supabase, or provide instructions
try:
    from supabase import create_client, Client
except ImportError:
    print("❌ 'supabase' library not found. Please run: pip install supabase")
    sys.exit(1)

def load_recipes(directory):
    recipes_found = []
    path = Path(directory)
    
    if not path.exists():
        print(f"❌ Directory not found: {directory}")
        return []

    print(f"🔍 Scanning for Recipes in: {directory}")
    
    for file_path in path.rglob('*.json'):
        if "Grinders" in str(file_path) or "lottie" in str(file_path).lower():
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                if isinstance(data, list):
                    for recipe in data:
                        recipes_found.append((file_path, recipe))
                elif isinstance(data, dict):
                    if 'title' in data and 'brewing_method' in data:
                        recipes_found.append((file_path, data))
        except Exception as e:
            print(f"⚠️ Error reading {file_path}: {e}")
            
    return recipes_found

def load_grinders(directory):
    grinders_found = []
    path = Path(directory)
    
    if not path.exists():
        return []
        
    print(f"🔍 Scanning for Grinders in: {directory}")
    
    # We look specifically in Grinders folder
    # Assuming standard structure Resources/Grinders/...
    grinder_path = path.parent / "Grinders"
    if not grinder_path.exists():
        # Fallback if user pointed deeper
        return []

    for file_path in grinder_path.rglob('*.json'):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                # Check for grinder structure
                if 'name' in data and 'method' in data and 'settings' in data:
                    grinders_found.append((file_path, data))
        except Exception as e:
            print(f"⚠️ Error reading grinder {file_path}: {e}")
            
    return grinders_found

def main():
    parser = argparse.ArgumentParser(description='Migrate local JSON recipes and grinders to Supabase')
    parser.add_argument('--url', required=True, help='Supabase Project URL')
    parser.add_argument('--key', required=True, help='Supabase Service Role Key (for writing)')
    parser.add_argument('--dir', default='PerfectBrew/Resources/Recipes', help='Directory containing recipe JSONs')
    
    args = parser.parse_args()
    
    try:
        supabase: Client = create_client(args.url, args.key)
    except Exception as e:
        print(f"❌ Failed to initialize Supabase client: {e}")
        sys.exit(1)
        
    # --- RECIPES ---
    recipes = load_recipes(args.dir)
    print(f"📊 Found {len(recipes)} recipes.")
    
    for _, recipe in recipes:
        title = recipe.get('title', 'Unknown')
        method = recipe.get('brewing_method', 'Unknown')
        print(f"🚀 Uploading Recipe: {title} ({method})...")
        
        payload = {
            "title": title,
            "method": method,
            "json_data": recipe,
            "version": 1
        }
        
        try:
            existing = supabase.table('recipes').select("id").eq("title", title).execute()
            if existing.data and len(existing.data) > 0:
                print(f"   🔄 Updating...")
                supabase.table('recipes').update(payload).eq("id", existing.data[0]['id']).execute()
            else:
                supabase.table('recipes').insert(payload).execute()
            print("   ✅ Done")
        except Exception as e:
            print(f"   ❌ Error: {e}")

    # --- GRINDERS ---
    grinders = load_grinders(args.dir)
    print(f"\n📊 Found {len(grinders)} grinder settings.")
    
    for _, grinder in grinders:
        name = grinder.get('name', 'Unknown')
        method = grinder.get('method', 'Unknown')
        settings = grinder.get('settings', {})
        
        print(f"⚙️ Uploading Grinder: {name} for {method}...")
        
        # We store the 'settings' object as the json_data
        # Note: The table schema calls it 'settings_json'
        payload = {
            "name": name,
            "method": method,
            "settings_json": settings
        }
        
        try:
            # Check unique by name + method
            existing = supabase.table('grinders').select("id").eq("name", name).eq("method", method).execute()
            
            if existing.data and len(existing.data) > 0:
                print(f"   🔄 Updating...")
                supabase.table('grinders').update(payload).eq("id", existing.data[0]['id']).execute()
            else:
                supabase.table('grinders').insert(payload).execute()
            print("   ✅ Done")
        except Exception as e:
            print(f"   ❌ Error: {e}")

if __name__ == "__main__":
    main()
