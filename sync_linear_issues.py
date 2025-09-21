#!/usr/bin/env python3
"""
Linear Issues Sync Script for PerfectBrew
Automatically syncs Linear issues to local markdown files
"""

import os
import json
import requests
from datetime import datetime
from typing import Dict, List, Any

class LinearIssuesSync:
    def __init__(self):
        self.base_dir = "Linear_Issues"
        self.api_token = os.getenv("LINEAR_API_TOKEN", "YOUR_LINEAR_API_TOKEN_HERE")
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
        self.base_url = "https://api.linear.app/graphql"
    
    def get_all_issues(self) -> List[Dict]:
        """Get all issues from Linear using GraphQL API"""
        query = """
        query {
          issues {
            nodes {
              id
              title
              description
              identifier
              priority
              url
              createdAt
              updatedAt
              state {
                id
                name
                type
                color
              }
              team {
                id
                name
                key
              }
              assignee {
                id
                name
                displayName
              }
              project {
                id
                name
              }
              labels {
                nodes {
                  id
                  name
                  color
                }
              }
            }
          }
        }
        """
        
        try:
            response = requests.post(
                self.base_url,
                headers=self.headers,
                json={"query": query}
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get("data", {}).get("issues", {}).get("nodes", [])
            else:
                print(f"❌ Error fetching issues: {response.status_code}")
                return []
        except Exception as e:
            print(f"❌ Error connecting to Linear API: {e}")
            return []
    
    def create_issue_markdown(self, issue: Dict) -> str:
        """Create markdown content for an issue"""
        
        # Extract issue details
        issue_id = issue.get("identifier", "Unknown")
        title = issue.get("title", "No title")
        description = issue.get("description", "No description")
        url = issue.get("url", "")
        
        state = issue.get("state", {})
        state_name = state.get("name", "Unknown")
        state_type = state.get("type", "unknown")
        
        team = issue.get("team", {})
        team_name = team.get("name", "Unknown")
        
        assignee = issue.get("assignee")
        assignee_name = assignee.get("name", "Unassigned") if assignee else "Unassigned"
        
        project = issue.get("project")
        project_name = project.get("name", "No project") if project else "No project"
        
        priority = issue.get("priority", 0)
        priority_text = {0: "No priority", 1: "Urgent", 2: "High", 3: "Normal", 4: "Low"}.get(priority, "Unknown")
        
        labels = issue.get("labels", {}).get("nodes", [])
        label_names = [label.get("name", "") for label in labels]
        
        created_at = issue.get("createdAt", "")
        updated_at = issue.get("updatedAt", "")
        
        # Priority emoji
        priority_emoji = {1: "🚨", 2: "🔥", 3: "📋", 4: "📝", 0: "⚪"}.get(priority, "❓")
        
        # State emoji
        state_emoji = {
            "backlog": "📋",
            "unstarted": "⏳", 
            "started": "🔄",
            "completed": "✅",
            "canceled": "❌"
        }.get(state_type, "❓")
        
        markdown = f"""# {issue_id}: {title}

**🔗 Linear URL:** {url}

## 📋 Issue Details

- **ID:** {issue_id}
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
        
        return markdown
    
    def get_folder_for_issue(self, issue: Dict) -> str:
        """Determine which folder an issue should go in"""
        
        state = issue.get("state", {})
        state_type = state.get("type", "unknown")
        state_name = state.get("name", "Unknown")
        
        labels = issue.get("labels", {}).get("nodes", [])
        label_names = [label.get("name", "").lower() for label in labels]
        
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
            return "Backlog"  # Default
    
    def sync_issues(self):
        """Main sync function"""
        print("🔄 Syncing Linear Issues to Local Markdown Files...")
        print("=" * 60)
        
        # Get all issues
        issues = self.get_all_issues()
        if not issues:
            print("❌ No issues found or API error")
            return
        
        print(f"📥 Found {len(issues)} issues to sync")
        
        # Create base directory structure
        folders = ["Backlog", "Todo", "InProgress", "Done", "Bugs", "Features", "Improvements", "Canceled"]
        for folder in folders:
            os.makedirs(f"{self.base_dir}/{folder}", exist_ok=True)
        
        # Clear existing files (optional - comment out if you want to keep manual edits)
        # for folder in folders:
        #     for file in os.listdir(f"{self.base_dir}/{folder}"):
        #         if file.endswith(".md") and file != "README.md":
        #             os.remove(f"{self.base_dir}/{folder}/{file}")
        
        # Process each issue
        issue_counts = {folder: 0 for folder in folders}
        
        for issue in issues:
            issue_id = issue.get("identifier", "Unknown")
            title = issue.get("title", "No title")
            
            # Create safe filename
            safe_title = "".join(c for c in title if c.isalnum() or c in " -_").strip()
            safe_title = safe_title.replace(" ", "_")[:50]  # Limit length
            
            # Determine folder
            folder = self.get_folder_for_issue(issue)
            issue_counts[folder] += 1
            
            # Create markdown content
            markdown_content = self.create_issue_markdown(issue)
            
            # Write file
            filename = f"{issue_id}_{safe_title}.md"
            filepath = f"{self.base_dir}/{folder}/{filename}"
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(markdown_content)
            
            print(f"  ✅ {folder}/{filename}")
        
        # Create updated README
        self.create_readme(issue_counts, len(issues))
        
        print("\n" + "=" * 60)
        print("🎉 Linear Issues sync completed!")
        print(f"📊 Total issues: {len(issues)}")
        for folder, count in issue_counts.items():
            if count > 0:
                print(f"   {folder}: {count}")
    
    def create_readme(self, issue_counts: Dict[str, int], total_issues: int):
        """Create updated README with current stats"""
        
        readme_content = f"""# 📋 PerfectBrew Linear Issues

**Organization:** aechavarria  
**Team:** Aechavarria (AEC)  
**Project:** PerfectBrew  
**Total Issues:** {total_issues}  
**Last Synced:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

---

## 📊 Issues by Status

"""
        
        status_emojis = {
            "Bugs": "🐛",
            "Features": "⭐",
            "Improvements": "🔧",
            "Todo": "⏳",
            "InProgress": "🔄", 
            "Done": "✅",
            "Backlog": "📋",
            "Canceled": "❌"
        }
        
        for folder, count in issue_counts.items():
            if count > 0:
                emoji = status_emojis.get(folder, "📄")
                readme_content += f"### {emoji} {folder} ({count} issues)\n"
                
                # List files in this folder
                folder_path = f"{self.base_dir}/{folder}"
                if os.path.exists(folder_path):
                    files = [f for f in os.listdir(folder_path) if f.endswith(".md") and f != "README.md"]
                    for file in sorted(files):
                        issue_name = file.replace(".md", "").replace("_", " ")
                        readme_content += f"- **[{issue_name}]({folder}/{file})**\n"
                
                readme_content += "\n"
        
        readme_content += f"""---

## 🔄 How to Update

Run this command to sync with Linear:
```bash
python3 sync_linear_issues.py
```

## 🎯 Quick Actions

### Create New Issue:
```python
# Example: Create bug
mcp_linear_linear_createIssue(
    title="Bug: Description here",
    teamId="81773f75-66de-49e6-a768-3c704f47052d",
    projectId="1bb68553-74a7-456c-b19f-4f77aedbc93c",
    priority=2,
    labelIds=["b502fe98-c2a6-4bc3-a406-71550efcb61e"]  # Bug label
)
```

### Update Issue Status:
```python
# Mark as Done
mcp_linear_linear_updateIssue(
    id="issue-id",
    stateId="bcdbf5bb-19d2-4adb-9299-c4094ba121cb"  # Done state
)
```

**Your Linear workspace is synchronized and ready for development!** 🚀
"""
        
        with open(f"{self.base_dir}/README.md", 'w', encoding='utf-8') as f:
            f.write(readme_content)

if __name__ == "__main__":
    syncer = LinearIssuesSync()
    syncer.sync_issues()
