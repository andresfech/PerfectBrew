#!/usr/bin/env python3
"""
Linear Issues Sync using MCP Integration
Simple script to sync Linear issues to markdown files
"""

import os
import json
from datetime import datetime

def create_issue_markdown(issue_data):
    """Create markdown content from MCP issue data"""
    
    # Parse the issue data (assuming it's from MCP Linear calls)
    issue_id = issue_data.get("id", "Unknown")
    title = issue_data.get("title", "No title")
    description = issue_data.get("description", "No description")
    url = issue_data.get("url", "")
    
    state = issue_data.get("state", {})
    state_name = state.get("name", "Unknown") if state else "Unknown"
    state_type = state.get("type", "unknown") if state else "unknown"
    
    team = issue_data.get("team", {})
    team_name = team.get("name", "Unknown") if team else "Unknown"
    
    assignee = issue_data.get("assignee")
    assignee_name = assignee.get("name", "Unassigned") if assignee else "Unassigned"
    
    project = issue_data.get("project")
    project_name = project.get("name", "No project") if project else "No project"
    
    priority = issue_data.get("priority", 0)
    priority_text = {0: "No priority", 1: "Urgent", 2: "High", 3: "Normal", 4: "Low"}.get(priority, "Unknown")
    
    labels = issue_data.get("labels", [])
    label_names = [label.get("name", "") for label in labels] if labels else []
    
    created_at = issue_data.get("createdAt", "")
    updated_at = issue_data.get("updatedAt", "")
    
    # Extract identifier from URL or use ID
    identifier = url.split("/")[-1].split("-")[0] + "-" + url.split("/")[-1].split("-")[1] if url else issue_id[:8]
    
    # Priority and state emojis
    priority_emoji = {1: "🚨", 2: "🔥", 3: "📋", 4: "📝", 0: "⚪"}.get(priority, "❓")
    state_emoji = {
        "backlog": "📋",
        "unstarted": "⏳", 
        "started": "🔄",
        "completed": "✅",
        "canceled": "❌"
    }.get(state_type, "❓")
    
    markdown = f"""# {identifier}: {title}

**🔗 Linear URL:** {url}

## 📋 Issue Details

- **ID:** {identifier}
- **Status:** {state_emoji} {state_name}
- **Priority:** {priority_emoji} {priority_text} ({priority})
- **Team:** {team_name}
- **Project:** {project_name}
- **Assignee:** {assignee_name}
- **Labels:** {', '.join(label_names) if label_names else 'None'}
- **Created:** {created_at}
- **Updated:** {updated_at}

## 📝 Description

{description}

---
*Last synced: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
    
    return markdown, identifier

def get_folder_for_issue(issue_data):
    """Determine folder based on issue data"""
    
    state = issue_data.get("state", {})
    state_type = state.get("type", "unknown") if state else "unknown"
    
    labels = issue_data.get("labels", [])
    label_names = [label.get("name", "").lower() for label in labels] if labels else []
    
    # Organize by label first, then by status
    if "bug" in label_names:
        return "Bugs"
    elif "feature" in label_names:
        return "Features"
    elif "improvement" in label_names:
        return "Improvements"
    elif state_type == "completed":
        return "Done"
    elif state_type == "started":
        return "InProgress"
    elif state_type == "unstarted":
        return "Todo"
    elif state_type == "backlog":
        return "Backlog"
    elif state_type == "canceled":
        return "Canceled"
    else:
        return "Backlog"

def main():
    """
    Main function - expects issues data from MCP calls
    
    Usage:
    1. Run MCP Linear commands in Cursor to get issues
    2. Copy the JSON output to 'linear_issues_data.json'
    3. Run this script: python3 sync_linear_mcp.py
    """
    
    print("🔄 Linear Issues MCP Sync")
    print("=" * 50)
    
    # Check if we have MCP data file
    if os.path.exists("linear_issues_data.json"):
        print("📥 Loading issues from linear_issues_data.json...")
        with open("linear_issues_data.json", 'r') as f:
            issues = json.load(f)
    else:
        print("❌ No linear_issues_data.json found")
        print("\n💡 To use this script:")
        print("1. Run MCP Linear commands in Cursor")
        print("2. Save JSON output to 'linear_issues_data.json'")
        print("3. Run this script again")
        return
    
    # Create directory structure
    base_dir = "Linear_Issues"
    folders = ["Backlog", "Todo", "InProgress", "Done", "Bugs", "Features", "Improvements", "Canceled"]
    
    for folder in folders:
        os.makedirs(f"{base_dir}/{folder}", exist_ok=True)
    
    # Process issues
    issue_counts = {folder: 0 for folder in folders}
    
    for issue in issues:
        title = issue.get("title", "No title")
        
        # Create markdown
        markdown_content, identifier = create_issue_markdown(issue)
        
        # Determine folder
        folder = get_folder_for_issue(issue)
        issue_counts[folder] += 1
        
        # Create filename
        safe_title = "".join(c for c in title if c.isalnum() or c in " -_").strip()
        safe_title = safe_title.replace(" ", "_")[:50]
        filename = f"{identifier}_{safe_title}.md"
        
        # Write file
        filepath = f"{base_dir}/{folder}/{filename}"
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        
        print(f"  ✅ {folder}/{filename}")
    
    print(f"\n🎉 Synced {len(issues)} issues!")
    for folder, count in issue_counts.items():
        if count > 0:
            print(f"   {folder}: {count}")

if __name__ == "__main__":
    main()
