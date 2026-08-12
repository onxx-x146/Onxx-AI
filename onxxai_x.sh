#!/bin/bash
#================================================================================
#                         ONXX AI - TERMINAL ASSISTANT
#                    Created by: Hari Jadhav
#                    GitHub: https://github.com/onxx-x143
#================================================================================

# --------------------------- CONFIGURATION -------------------------------------
# USER: Replace these with your actual OpenRouter API Key and Model
OPENROUTER_API_KEY="sk_API_Key"
OPENROUTER_MODEL="inclusionai/ling-3.0-flash:free"

# GitHub Redirect URL
GITHUB_URL="https://github.com/onxx-x146"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --------------------------- BANNER FUNCTION -----------------------------------
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "    ██████  ███▄    █ ▒██   ██▒ ██▓     ▄▄▄       ██▓"
    echo "  ▒██    ▒  ██ ▀█   █ ▒▒ █ █ ▒░▓██▒    ▒████▄    ▓██▒"
    echo "  ░ ▓██▄   ▓██  ▀█ ██▒░░  █   ░▒██░    ▒██  ▀█▄  ▒██▒"
    echo "    ▒   ██▒▓██▒  ▐▌██▒ ░ █ █ ▒ ▒██░    ░██▄▄▄▄██ ░██░"
    echo "  ▒██████▒▒▒██░   ▓██░▒██▒ ▒██▒░██████▒ ▓█   ▓██▒░██░"
    echo "  ▒ ▒▓▒ ▒ ░░ ▒░   ▒ ▒ ▒▒ ░ ░▓ ░░ ▒░▓  ░ ▒▒   ▓▒█░░▓  "
    echo "  ░ ░▒  ░ ░░ ░░   ░ ▒░░░   ░▒ ░░ ░ ▒  ░  ▒   ▒▒ ░ ▒ ░"
    echo "  ░  ░  ░     ░   ░ ░  ░    ░    ░ ░     ░   ▒    ▒ ░"
    echo "        ░           ░  ░    ░      ░  ░      ░  ░ ░  "
    echo ""
    echo -e "${MAGENTA}${BOLD}              ╔═══════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}${BOLD}              ║      ${CYAN}T E R M I N A L   A I${MAGENTA}         ║${NC}"
    echo -e "${MAGENTA}${BOLD}              ╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}              ✦ Created by: ${BOLD}ONXX${NC}${YELLOW} ✦${NC}"
    echo -e "${GREEN}              ✦ GitHub: ${BOLD}github.com/onxx-x146${NC}${GREEN} ✦${NC}"
    echo -e "${CYAN}              ✦ Instagram by: ${BOLD}__.l2l__ ${NC}${CYAN} ✦${NC}"
    echo ""
    echo -e "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# --------------------------- GITHUB REDIRECT -----------------------------------
github_redirect() {
    echo -e "${BLUE}[INFO]${NC} Redirecting to GitHub profile..."
    sleep 1

    if command -v termux-open-url &> /dev/null; then
        termux-open-url "$GITHUB_URL"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$GITHUB_URL"
    elif command -v am &> /dev/null; then
        am start -a android.intent.action.VIEW -d "$GITHUB_URL" &> /dev/null
    else
        echo -e "${YELLOW}[WARN]${NC} Could not auto-open browser. Please visit:"
        echo -e "${CYAN}$GITHUB_URL${NC}"
    fi
    echo ""
}

# --------------------------- LOADING ANIMATION ---------------------------------
loading_animation() {
    local msg
    msg="$1"
    echo -ne "${YELLOW}[⏳] $msg${NC} "
    for i in {1..3}; do
        echo -ne "."
        sleep 0.4
    done
    echo ""
}

# --------------------------- CHECK DEPENDENCIES -------------------------------
check_dependencies() {
    local missing
    missing=()

    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}[ERROR]${NC} Missing dependencies: ${missing[*]}"
        echo -e "${YELLOW}[INFO]${NC} Installing required packages..."
        pkg update -y && pkg install -y "${missing[@]}"

        # Verify installation succeeded
        local still_missing
        still_missing=()
        if ! command -v curl &> /dev/null; then
            still_missing+=("curl")
        fi
        if ! command -v jq &> /dev/null; then
            still_missing+=("jq")
        fi

        if [ ${#still_missing[@]} -ne 0 ]; then
            echo -e "${RED}[FATAL]${NC} Failed to install: ${still_missing[*]}"
            echo -e "${YELLOW}[INFO]${NC} Please install manually: pkg install ${still_missing[*]}"
            exit 1
        fi

        echo -e "${GREEN}[✓]${NC} All dependencies installed successfully!"
    fi
}

# --------------------------- API CALL FUNCTION ---------------------------------
call_openrouter() {
    local user_prompt
    user_prompt="$1"
    local system_msg
    system_msg="$2"

    # FIX 1: Proper API Key validation (check for placeholder or empty)
    if [ -z "$OPENROUTER_API_KEY" ] || [ "$OPENROUTER_API_KEY" = "YOUR_OPENROUTER_API_KEY_HERE" ] || [ "$OPENROUTER_API_KEY" = "PLACEHOLDER" ]; then
        echo -e "${RED}[ERROR]${NC} Please set your OpenRouter API Key in the script!"
        echo -e "${YELLOW}[INFO]${NC} Get your free API key from: https://openrouter.ai/keys"
        return 1
    fi

    # FIX 1: Proper Model validation
    if [ -z "$OPENROUTER_MODEL" ] || [ "$OPENROUTER_MODEL" = "YOUR_MODEL_NAME_HERE" ] || [ "$OPENROUTER_MODEL" = "PLACEHOLDER" ]; then
        echo -e "${RED}[ERROR]${NC} Please set your Model name in the script!"
        echo -e "${YELLOW}[INFO]${NC} Example models: meta-llama/llama-3.1-8b-instruct, google/gemma-2-9b-it, inclusionai/ling-3.0-flash:free"
        return 1
    fi

    loading_animation "Thinking"

    # FIX 2: Build JSON safely using jq to prevent quote injection attacks
    local json_payload
    json_payload=$(jq -n \
        --arg model "$OPENROUTER_MODEL" \
        --arg system "$system_msg" \
        --arg user "$user_prompt" \
        '{
            model: $model,
            messages: [
                {role: "system", content: $system},
                {role: "user", content: $user}
            ]
        }')

    if [ $? -ne 0 ] || [ -z "$json_payload" ]; then
        echo -e "${RED}[ERROR]${NC} Failed to build API request!"
        return 1
    fi

    local response
    # FIX 4: Added --max-time 30 to prevent hanging on slow network
    response=$(curl -s --max-time 30 -X POST "https://openrouter.ai/api/v1/chat/completions" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "HTTP-Referer: https://github.com/onxx-x143" \
        -H "X-Title: OnxxAI" \
        -d "$json_payload" 2>/dev/null)

    local curl_status
    curl_status=$?

    if [ $curl_status -eq 28 ]; then
        echo -e "${RED}[ERROR]${NC} Request timed out! Check your internet connection."
        return 1
    elif [ $curl_status -ne 0 ]; then
        echo -e "${RED}[ERROR]${NC} Failed to connect to OpenRouter API (curl exit: $curl_status)!"
        return 1
    fi

    # Extract response content using jq
    local content
    content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)

    if [ -z "$content" ] || [ "$content" = "null" ]; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.error.message // "Unknown API Error"' 2>/dev/null)
        echo -e "${RED}[API ERROR]${NC} $error_msg"
        return 1
    fi

    echo "$content"
    return 0
}

# --------------------------- CODE GENERATION ----------------------------------
generate_code() {
    local lang
    lang="$1"
    local prompt
    prompt="$2"

    local system_msg
    system_msg="You are OnxxAI, an expert code generator created by Hari Jadhav. Generate clean, well-commented, production-ready code. Only output the code with brief comments. Do not add explanations outside the code unless asked."

    local full_prompt
    full_prompt="Generate $lang code for: $prompt"

    echo -e "${CYAN}[OnxxAI]${NC} Generating ${BOLD}$lang${NC} code..."
    echo ""

    local code
    code=$(call_openrouter "$full_prompt" "$system_msg")

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}Generated $lang Code:${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "$code"
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        # Ask to save
        echo -ne "${YELLOW}[?]${NC} Save this code to file? (y/n): "
        read -r save_choice
        if [[ "$save_choice" =~ ^[Yy]$ ]]; then
            echo -ne "${YELLOW}[?]${NC} Enter filename: "
            read -r filename
            echo "$code" > "$filename"
            echo -e "${GREEN}[✓]${NC} Code saved to: ${BOLD}$filename${NC}"
        fi
    fi
}

# --------------------------- CUSTOM BANNER GENERATOR --------------------------
generate_banner() {
    local text
    text="$1"

    local system_msg
    system_msg="You are an ASCII art banner generator. Create beautiful, creative ASCII art banners. Use only ASCII characters. Make it impressive and artistic."

    local full_prompt
    full_prompt="Create a beautiful ASCII art banner for: '$text'. Make it creative and visually stunning using ASCII characters only."

    echo -e "${CYAN}[OnxxAI]${NC} Generating banner for: ${BOLD}$text${NC}"

    local banner
    banner=$(call_openrouter "$full_prompt" "$system_msg")

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo "$banner"
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        echo -ne "${YELLOW}[?]${NC} Save banner to file? (y/n): "
        read -r save_choice
        if [[ "$save_choice" =~ ^[Yy]$ ]]; then
            echo -ne "${YELLOW}[?]${NC} Enter filename: "
            read -r filename
            echo "$banner" > "$filename"
            echo -e "${GREEN}[✓]${NC} Banner saved to: ${BOLD}$filename${NC}"
        fi
    fi
}

# --------------------------- GENERAL CHAT -------------------------------------
general_chat() {
    local prompt
    prompt="$1"

    local system_msg
    system_msg="You are OnxxAI, a powerful AI assistant created by Hari Jadhav. You are running in Termux on Android. You can help with coding, explanations, problem-solving, and creative tasks. Be helpful, concise, and friendly. If asked to write code, provide clean, well-commented code."

    local response
    response=$(call_openrouter "$prompt" "$system_msg")

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}${BOLD}[OnxxAI]:${NC}"
        echo "$response"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
}

# --------------------------- SHOW HELP ----------------------------------------
show_help() {
    echo -e "${YELLOW}${BOLD}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}${BOLD}                           ONXX AI - COMMAND HELP                             ${NC}"
    echo -e "${YELLOW}${BOLD}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}General Commands:${NC}"
    echo -e "  ${GREEN}help${NC}              - Show this help menu"
    echo -e "  ${GREEN}clear${NC}             - Clear screen and show banner"
    echo -e "  ${GREEN}exit / quit${NC}       - Exit OnxxAI"
    echo -e "  ${GREEN}github${NC}            - Open GitHub profile (onxx-x143)"
    echo -e "  ${GREEN}banner <text>${NC}     - Generate ASCII art banner"
    echo ""
    echo -e "${CYAN}${BOLD}Code Generation Commands:${NC}"
    echo -e "  ${GREEN}code python <desc>${NC}    - Generate Python code"
    echo -e "  ${GREEN}code java <desc>${NC}      - Generate Java code"
    echo -e "  ${GREEN}code html <desc>${NC}      - Generate HTML code"
    echo -e "  ${GREEN}code css <desc>${NC}       - Generate CSS code"
    echo -e "  ${GREEN}code js <desc>${NC}        - Generate JavaScript code"
    echo -e "  ${GREEN}code bash <desc>${NC}      - Generate Bash script"
    echo -e "  ${GREEN}code json <desc>${NC}      - Generate JSON data"
    echo -e "  ${GREEN}code cpp <desc>${NC}       - Generate C++ code"
    echo -e "  ${GREEN}code c <desc>${NC}         - Generate C code"
    echo -e "  ${GREEN}code php <desc>${NC}       - Generate PHP code"
    echo -e "  ${GREEN}code sql <desc>${NC}       - Generate SQL queries"
    echo -e "  ${GREEN}code react <desc>${NC}     - Generate React code"
    echo -e "  ${GREEN}code any <desc>${NC}       - Generate code in any language"
    echo ""
    echo -e "${CYAN}${BOLD}Examples:${NC}"
    echo -e "  ${YELLOW}code python${NC} 'Create a calculator with GUI'"
    echo -e "  ${YELLOW}code bash${NC} 'Backup script with datestamp'"
    echo -e "  ${YELLOW}banner${NC} 'HACKER ZONE'"
    echo ""
    echo -e "${YELLOW}${BOLD}══════════════════════════════════════════════════════════════════════════════${NC}"
}

# --------------------------- MAIN INTERACTIVE LOOP ----------------------------
main_loop() {
    while true; do
        echo -ne "${MAGENTA}${BOLD}[OnxxAI]${NC}${GREEN} ➜ ${NC}"
        read -r input

        # Trim leading/trailing whitespace
        input=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty input
        [ -z "$input" ] && continue

        # Convert to lowercase for command checking
        local cmd_lower
        cmd_lower=$(echo "$input" | awk '{print tolower($1)}')

        case "$cmd_lower" in
            "exit"|"quit")
                echo -e "${GREEN}[✓]${NC} Thank you for using ${BOLD}OnxxAI${NC}! Created by Hari Jadhav."
                echo -e "${CYAN}Visit: https://github.com/onxx-x143${NC}"
                exit 0
                ;;

            "help")
                show_help
                ;;

            "clear")
                show_banner
                ;;

            "github")
                github_redirect
                ;;

            "banner")
                local banner_text
                banner_text="${input#banner }"
                if [ -z "$banner_text" ] || [ "$banner_text" = "banner" ]; then
                    echo -ne "${YELLOW}[?]${NC} Enter banner text: "
                    read -r banner_text
                fi
                generate_banner "$banner_text"
                ;;

            "code")
                # FIX 3: Separate local declaration from assignment
                local lang
                lang=$(echo "$input" | awk '{print $2}')
                local desc
                desc=$(echo "$input" | cut -d' ' -f3-)

                if [ -z "$lang" ] || [ -z "$desc" ]; then
                    echo -e "${RED}[ERROR]${NC} Usage: code <language> <description>"
                    echo -e "${YELLOW}[INFO]${NC} Example: code python 'Create a web scraper'"
                    continue
                fi

                # Map short names to full names
                case "$lang" in
                    "py") lang="Python" ;;
                    "js") lang="JavaScript" ;;
                    "cpp") lang="C++" ;;
                    "sh") lang="Bash" ;;
                    *) lang=$(echo "$lang" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}') ;;
                esac

                generate_code "$lang" "$desc"
                ;;

            *)
                # General chat mode
                general_chat "$input"
                ;;
        esac
    done
}

# --------------------------- MAIN ENTRY POINT ---------------------------------
main() {
    # Check dependencies
    check_dependencies

    # Show banner
    show_banner

    # GitHub redirect on startup
    github_redirect

    # Welcome message
    echo -e "${GREEN}[✓]${NC} Welcome to ${BOLD}OnxxAI${NC} - Your Terminal AI Assistant!"
    echo -e "${GREEN}[✓]${NC} Created by: ${BOLD}Hari Jadhav${NC}"
    echo -e "${YELLOW}[i]${NC} Type ${BOLD}help${NC} to see available commands."
    echo ""

    # Check if API key is configured properly
    if [ -z "$OPENROUTER_API_KEY" ] || [ "$OPENROUTER_API_KEY" = "YOUR_OPENROUTER_API_KEY_HERE" ] || [ "$OPENROUTER_API_KEY" = "PLACEHOLDER" ]; then
        echo -e "${RED}[!] WARNING:${NC} OpenRouter API Key not configured!"
        echo -e "${YELLOW}[i]${NC} Please edit this script and set your API key."
        echo -e "${YELLOW}[i]${NC} Get free API key from: ${CYAN}https://openrouter.ai/keys${NC}"
        echo ""
    fi

    # Start interactive loop
    main_loop
}

# Run main function
main
