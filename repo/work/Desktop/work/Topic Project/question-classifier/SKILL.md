---
name: question-classifier
description: Classifies cropped question images into topics using Gemini API. Use this when you need to tag untagged question images in `data/output/cropped_questions/` based on the taxonomy in `data/output/topics.json`.
---

# Question Classifier Skill

This skill allows you to classify cropped question images into a hierarchical topic taxonomy using the Gemini API.

## Workflow

1.  **Check Environment**: Ensure `GOOGLE_API_KEY` is set in the environment.
2.  **Run Classification**: Execute the classification script in batches to respect rate limits.
    ```bash
    python3 app/classify_questions.py --batch-size 50 --delay 4
    ```
3.  **Monitor Progress**: Progress is tracked in `data/state/.classifier_progress.json`.
4.  **Review Tags**: Tags are stored in `data/output/question_tags.json`.
5.  **Topics Update**: If a new topic is identified, it is automatically added to `data/output/topics.json`.

## Configuration

-   **Batch Size**: Default is 50. Adjust based on your daily limit (Gemini Free Tier allows 1,500 RPD).
-   **Delay**: Default is 4 seconds. This ensures you stay within the 15 RPM limit for Gemini 1.5 Flash.

## Files

-   `app/classify_questions.py`: The main classification script.
-   `data/output/topics.json`: The taxonomy of topics.
-   `data/output/question_tags.json`: The output file mapping questions to topics.
-   `data/state/.classifier_progress.json`: Tracks processed images.