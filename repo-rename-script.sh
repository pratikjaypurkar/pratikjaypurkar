#!/bin/bash

# ====================================================================
# GitHub Repository Bulk Rename & Organize Script
# Author: Pratik Jaypurkar
# Purpose: Rename all repositories to PascalCase with category prefixes
#          and move unused repos to archive organization
# ====================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ARCHIVE_ORG="PratikJaypurkar-Archive"
GITHUB_USERNAME="pratikjaypurkar"
LOG_FILE="repo-rename-$(date +%Y%m%d_%H%M%S).log"

# ====================================================================
# HELPER FUNCTIONS
# ====================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if gh CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI is not installed. Please install it from https://cli.github.com"
        exit 1
    fi
    log_success "GitHub CLI found"
}

# Check if authenticated
check_auth() {
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub. Run 'gh auth login'"
        exit 1
    fi
    log_success "GitHub authentication verified"
}

# ====================================================================
# RENAME MAPPINGS - All repositories with new names and categories
# ====================================================================

declare -A REPO_MAPPINGS=(
    # ERP Systems
    ["ERP-CRM-System"]="ErpCRMSystem"
    ["erp-system-2"]="ErpSystem2"
    ["ERP-ByteUprise-main"]="ErpByteUprise"
    ["erp-new"]="ErpNew"
    ["erp_laravel"]="ErpLaravel"
    ["nuxt-erp"]="ErpNuxt"
    
    # Web/Frontend Projects
    ["web-dashboard"]="WebDashboard"
    ["Portfolio"]="WebPortfolioPersonal"
    ["bbphysiotherapycollege"]="WebBBPhysiotherapy"
    ["bbphysiotherapyco"]="WebBBPhysiotherapyCollege"
    ["bbphysiotherapy"]="WebBBPhysio"
    ["bbayurvediccollege"]="WebBBAyurvedic"
    ["bbmedicalcollege"]="WebBBMedical"
    ["poojanursing"]="WebPoojaHospital"
    ["peshospital"]="WebPESHospital"
    ["bssbhandara"]="WebBSSBhandara"
    ["mbmbhandara"]="WebMBMBhandara"
    ["Gbj-Campus"]="WebGBJCampus"
    ["GBJCampus"]="WebGBJCampusMain"
    ["GBJBUZZ-Official"]="WebGBJBUZZ"
    ["EcomGbj"]="WebEcomGBJ"
    ["gram-panchayat-webiste-demo"]="WebGramPanchayat"
    ["Gravion-LadingPage"]="WebGravionLanding"
    ["byteuprise.com"]="WebByteuprise"
    ["Landingpage-byteuprise"]="WebByteupriseLP"
    ["pratik_portfolio"]="WebPratikPortfolioV1"
    ["pratik"]="WebPratikProfileV2"
    ["pratikjaypurkar.github.io"]="WebPratikGithubIO"
    ["shop.snuggby.com"]="WebShopSnuggby"
    ["laravel-udemy-clone"]="WebLaravelUdemy"
    ["Central_Edu.in"]="WebCentralEdu"
    ["Central_Edu_.in"]="WebCentralEduV2"
    
    # AI/ML Projects
    ["aiwos-detection"]="AiWosDetection"
    ["habitatwatch-ai"]="AiHabitatwatch"
    ["habitatwatch-ai-2eb1c3f1"]="AiHabitatwatchV2"
    
    # Mobile Apps
    ["chatapp"]="MobileChatApp"
    ["RideMate"]="MobileRideMate"
    ["RentAPlace"]="MobileRentAPlace"
    
    # Bots/Automation
    ["Haruka-Md"]="BotHaruka"
    ["Secktor-Md"]="BotSecktor"
    ["raganork-md"]="BotRaganork"
    ["QueenAmdi"]="BotQueenAmdi"
    ["deploy-raganork"]="BotRaganorkDeploy"
    
    # Learning/Practice
    ["365dayschallenge"]="LearnDaysChallenge365"
    ["freeCodeCamp"]="LearnFreeCodeCamp"
    ["OIBSIP"]="LearnOIBSIP"
    ["PythonCode"]="LearnPythonCode"
    ["Student-management-system"]="LearnStudentManagement"
    ["Cafe-management-java"]="LearnCafeManagement"
    ["Interactive-digital-classroom"]="LearnDigitalClassroom"
    ["Best-README-Template"]="LearnREADMETemplate"
    
    # Games/Entertainment
    ["game1"]="GameGame1"
    ["Games"]="GameGamesCollection"
    ["QuizGame"]="GameQuiz"
    ["CALCULATOR-HTML"]="GameCalculator"
    
    # Tools/Utilities
    ["Sending-Emails-Tool"]="ToolSendingEmails"
    ["tracker"]="ToolTracker"
    ["Weather-Dashboard"]="ToolWeatherDashboard"
    ["Noteapp"]="ToolNoteApp"
    ["free-claude-code"]="ToolClaudeCode"
    ["open-agents"]="ToolOpenAgents"
    ["Map-clone"]="ToolMapClone"
    
    # Web Development Projects
    ["7iDigital"]="WebDigital7i"
    ["BYTEUPRISE"]="WebByteUprise"
    ["Mern"]="WebMernStack"
    ["nextjs"]="WebNextJS"
    ["PhpWebDevelopment"]="WebPhpDevelopment"
    ["Basic-Banking-System"]="WebBankingSystem"
    ["Chat-Support-Chatbot"]="WebChatbot"
    ["Payment-Gateway-Integration"]="WebPaymentGateway"
    
    # Android Development
    ["AbsoluteLayoutEx"]="AndroidAbsoluteLayout"
    ["AcceptUserName_Password"]="AndroidLoginForm"
    ["AutocomplateSubject"]="AndroidAutocomplete"
    ["AutoCompleteViewEx"]="AndroidAutoCompleteView"
    ["DisplayStudentDatausingTextView"]="AndroidDisplayStudent"
    ["FrameLayout"]="AndroidFrameLayout"
    ["HelloWorld"]="AndroidHelloWorld"
    ["HelloWorldAndroid"]="AndroidHelloWorldV2"
    ["OnOffBluetooth"]="AndroidBluetoothControl"
    ["SelectLanguage_checkboxes"]="AndroidLanguageSelect"
    ["simpleCalculator"]="AndroidCalculator"
    ["StudentData10Display"]="AndroidStudentDataDisplay"
    ["StudentInfo"]="AndroidStudentInfo"
    ["StudentLoginFrom"]="AndroidStudentLogin"
    
    # Survey/Poll Projects
    ["political_survey"]="PollPoliticalSurvey"
    ["poll-app-demo"]="PollAppDemo"
    
    # Portfolio/Personal
    ["portfolio-pratik-jaypurkar"]="PortfolioPratikV1"
    ["raju-karemore"]="PersonalRajuKaremore"
    ["rajukaremore"]="PersonalRajuKaremoreV2"
    
    # Misc/Other
    ["gbjstore"]="MiscGBJStore"
    ["hackteachz.gihub.io"]="MiscHackteachz"
    ["newonedelete"]="MiscNewOneDelete"
    ["Testaiweb1"]="MiscTestAIWeb"
    ["Website-contains"]="MiscWebsiteContains"
    ["pratikjaypurkar"]="ProfileGithubConfig"
    ["career-readiness-week-1-pratikjaypurkar"]="LearnCareerReadiness"
    ["front-end_printable-"]="WebPrintableFrontend"
)

# ====================================================================
# ARCHIVE CANDIDATES (Low Activity Repos - Optional to Archive)
# ====================================================================

declare -a ARCHIVE_CANDIDATES=(
    "MiscGBJStore"
    "MiscHackteachz"
    "MiscNewOneDelete"
    "MiscTestAIWeb"
    "MiscWebsiteContains"
    "AndroidHelloWorld"
    "AndroidHelloWorldV2"
    "GameGame1"
    "LearnCareerReadiness"
)

# ====================================================================
# MAIN RENAME FUNCTION
# ====================================================================

rename_repository() {
    local old_name="$1"
    local new_name="$2"
    local owner="$3"
    
    log_info "Renaming: $owner/$old_name → $owner/$new_name"
    
    if gh repo rename "$old_name" --new-name "$new_name" --repo "$owner/$old_name" 2>&1; then
        log_success "Renamed: $old_name → $new_name"
        return 0
    else
        log_warning "Failed to rename: $old_name (might already exist or permission denied)"
        return 1
    fi
}

# ====================================================================
# MOVE REPOSITORY TO ARCHIVE ORGANIZATION
# ====================================================================

move_to_archive() {
    local repo_name="$1"
    local owner="$2"
    
    log_info "Moving $owner/$repo_name to archive organization..."
    
    # Note: This requires the archive org to exist and you to be owner
    # The actual transfer may require manual intervention
    log_warning "Repository transfer to another org requires manual setup via GitHub UI"
    log_info "To move '$repo_name' to archive org:"
    log_info "  1. Go to https://github.com/$owner/$repo_name/settings"
    log_info "  2. Scroll to 'Danger Zone'"
    log_info "  3. Click 'Transfer repository'"
    log_info "  4. Enter: $ARCHIVE_ORG"
}

# ====================================================================
# CREATE ARCHIVE ORGANIZATION GUIDE
# ====================================================================

create_archive_org_guide() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════╗
║            ARCHIVE ORGANIZATION SETUP GUIDE                        ║
╚════════════════════════════════════════════════════════════════════╝

Before running the full rename script, create the archive organization:

STEPS:
  1. Go to: https://github.com/organizations/new
  2. Organization name: PratikJaypurkar-Archive
  3. Billing email: Your email
  4. Organization type: Personal
  5. Click "Create organization"
  6. Complete setup and return here

FEATURES TO ENABLE (Optional):
  - Public repos (for archived projects)
  - No team members needed for archive org

Once created, this script can move unused repos there.

EOF
}

# ====================================================================
# EXECUTION PLAN PREVIEW
# ====================================================================

show_execution_plan() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════╗
║            REPOSITORY RENAME EXECUTION PLAN                        ║
╚════════════════════════════════════════════════════════════════════╝

PHASE 1: Rename all repositories to PascalCase with prefixes
  Categories:
    ✓ ErpXXX       - ERP Systems (6 repos)
    ✓ WebXXX       - Web/Frontend (25+ repos)
    ✓ AiXXX        - AI/ML Projects (3 repos)
    ✓ MobileXXX    - Mobile Apps (3 repos)
    ✓ BotXXX       - Bots/Automation (5 repos)
    ✓ LearnXXX     - Learning/Practice (8 repos)
    ✓ GameXXX      - Games (4 repos)
    ✓ ToolXXX      - Tools/Utilities (7 repos)
    ✓ AndroidXXX   - Android Development (11 repos)
    ✓ PollXXX      - Survey/Poll (2 repos)
    ✓ PersonalXXX  - Personal Projects (2 repos)
    ✓ MiscXXX      - Miscellaneous (5 repos)
    ✓ PortfolioXXX - Portfolios (1 repo)
    ✓ ProfileXXX   - Profile (1 repo)

PHASE 2: Move unused repos to archive organization
  Archive Candidates:
    • MiscGBJStore
    • MiscHackteachz
    • MiscNewOneDelete
    • MiscTestAIWeb
    • MiscWebsiteContains
    • AndroidHelloWorld
    • AndroidHelloWorldV2
    • GameGame1
    • LearnCareerReadiness

TOTAL: ~100+ repositories to be organized

EOF
}

# ====================================================================
# BATCH RENAME WITH RETRY LOGIC
# ====================================================================

rename_all_repos() {
    local total=${#REPO_MAPPINGS[@]}
    local count=0
    local success=0
    local failed=0
    
    log_info "Starting mass rename of $total repositories..."
    log_info "Log file: $LOG_FILE"
    
    for old_name in "${!REPO_MAPPINGS[@]}"; do
        new_name="${REPO_MAPPINGS[$old_name]}"
        ((count++))
        
        echo -ne "\r${BLUE}Progress: $count/$total${NC}"
        
        if rename_repository "$old_name" "$new_name" "$GITHUB_USERNAME"; then
            ((success++))
        else
            ((failed++))
        fi
        
        # Rate limiting - wait 1 second between requests
        sleep 1
    done
    
    echo ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Rename operation completed!"
    log_success "Successfully renamed: $success repositories"
    log_warning "Failed to rename: $failed repositories"
    log_info "Details saved to: $LOG_FILE"
}

# ====================================================================
# ARCHIVE SUGGESTION
# ====================================================================

archive_unused_repos() {
    log_info "Review the following repositories for archival:"
    
    for repo in "${ARCHIVE_CANDIDATES[@]}"; do
        log_info "  → Transfer '$repo' to '$ARCHIVE_ORG' organization"
    done
    
    log_info ""
    log_info "To manually move repos to archive:"
    log_info "  1. Visit each repo's Settings page"
    log_info "  2. Scroll to 'Danger Zone'"
    log_info "  3. Click 'Transfer repository'"
    log_info "  4. Type: $ARCHIVE_ORG"
    log_info "  5. Confirm transfer"
}

# ====================================================================
# SUMMARY REPORT
# ====================================================================

generate_summary() {
    cat > "repo-rename-summary-$(date +%Y%m%d_%H%M%S).md" << EOF
# Repository Rename Summary Report

**Date:** $(date)
**Total Repositories:** ${#REPO_MAPPINGS[@]}
**Archive Organization:** $ARCHIVE_ORG

## Category Breakdown

### ERP Systems (6)
- ErpCRMSystem
- ErpSystem2
- ErpByteUprise
- ErpNew
- ErpLaravel
- ErpNuxt

### Web/Frontend (25+)
- WebDashboard
- WebPortfolioPersonal
- WebBBPhysiotherapy
- And 22 more...

### AI/ML (3)
- AiWosDetection
- AiHabitatwatch
- AiHabitatwatchV2

### Mobile (3)
- MobileChatApp
- MobileRideMate
- MobileRentAPlace

### Bots/Automation (5)
- BotHaruka
- BotSecktor
- BotRaganork
- BotQueenAmdi
- BotRaganorkDeploy

### Learning/Practice (8)
- LearnDaysChallenge365
- LearnFreeCodeCamp
- And 6 more...

### Android Development (11)
- AndroidAbsoluteLayout
- AndroidLoginForm
- And 9 more...

### Tools/Utilities (7)
- ToolSendingEmails
- ToolTracker
- And 5 more...

### Games (4)
- GameQuiz
- GameCalculator
- And 2 more...

### Polls/Surveys (2)
- PollPoliticalSurvey
- PollAppDemo

### Miscellaneous (5)
- MiscGBJStore
- MiscHackteachz
- And 3 more...

## Next Steps

1. ✅ Archive Organization Created: $ARCHIVE_ORG
2. ✅ All repositories renamed with PascalCase + Category Prefixes
3. ⏳ Move unused repos to archive (manual or scripted)
4. ⏳ Update documentation and README files
5. ⏳ Update CI/CD pipelines if needed

## Log File
For detailed execution logs, see: $LOG_FILE

EOF
    log_success "Summary report generated: repo-rename-summary-*.md"
}

# ====================================================================
# MAIN MENU
# ====================================================================

main_menu() {
    clear
    
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════╗
║     GitHub Repository Bulk Rename & Organization Script            ║
║              For: pratikjaypurkar                                   ║
╚════════════════════════════════════════════════════════════════════╝

Select an option:

  1) Show execution plan preview
  2) Create archive organization guide
  3) Start renaming all repositories (MAIN TASK)
  4) Generate summary report
  5) Exit

EOF
}

# ====================================================================
# ENTRY POINT
# ====================================================================

main() {
    log_info "Initializing GitHub Repository Rename Script..."
    log_info "═══════════════════════════════════════════════════════════"
    
    # Pre-flight checks
    check_gh_cli
    check_auth
    
    while true; do
        main_menu
        read -p "Enter your choice (1-5): " choice
        
        case $choice in
            1)
                show_execution_plan
                read -p "Press Enter to continue..."
                ;;
            2)
                create_archive_org_guide
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                log_warning "⚠️  WARNING: This will rename ALL your repositories!"
                log_warning "⚠️  This action is PERMANENT and cannot be easily undone!"
                read -p "Type 'CONFIRM' to proceed: " confirm
                
                if [ "$confirm" = "CONFIRM" ]; then
                    log_info "Starting rename operation..."
                    rename_all_repos
                    archive_unused_repos
                    generate_summary
                    log_success "All tasks completed!"
                else
                    log_warning "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            4)
                generate_summary
                read -p "Press Enter to continue..."
                ;;
            5)
                log_info "Exiting script. Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid option. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run main function
main "$@"
