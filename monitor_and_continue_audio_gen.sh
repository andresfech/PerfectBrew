#!/bin/bash
# Monitor audio generation and continue with next method when done

METHODS=("AeroPress" "V60" "FrenchPress")
BASE_DIR="/Users/home/Documents/Programando/PerfectBrew"

for method in "${METHODS[@]}"; do
    echo "🚀 Starting Spanish audio generation for: $method"
    echo "=" | awk '{printf "%.0s=", 1..60}'
    echo ""
    
    # Run the generation
    cd "$BASE_DIR" || exit 1
    python3 generate_spanish_audio_batch.py --method "$method"
    
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo ""
        echo "✅ Completed: $method"
        echo ""
        
        # Count generated files
        case "$method" in
            "AeroPress")
                AUDIO_DIR="$BASE_DIR/PerfectBrew/Resources/Audio/AeroPress"
                ;;
            "V60")
                AUDIO_DIR="$BASE_DIR/PerfectBrew/Resources/Audio/V60"
                ;;
            "FrenchPress")
                AUDIO_DIR="$BASE_DIR/PerfectBrew/Resources/Audio/French_Press"
                ;;
        esac
        
        if [ -d "$AUDIO_DIR" ]; then
            FILE_COUNT=$(find "$AUDIO_DIR" -name "*_es.m4a" | wc -l | tr -d ' ')
            echo "📊 Generated $FILE_COUNT Spanish audio files for $method"
        fi
    else
        echo "❌ Error generating audio for $method (exit code: $EXIT_CODE)"
        echo "Stopping batch generation."
        exit 1
    fi
    
    echo ""
    echo "⏳ Waiting 5 seconds before next method..."
    sleep 5
    echo ""
done

echo "=" | awk '{printf "%.0s=", 1..60}'
echo "🎉 ALL METHODS COMPLETE!"
echo "=" | awk '{printf "%.0s=", 1..60}'


