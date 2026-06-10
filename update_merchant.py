import os
import re

directory = '/Users/arafathossain/trackai/medai land'
files = ['refund.html', 'trademarks.html', 'privacy.html', 'terms.html', 'compliance.html', 'index.html', 'scripts.js', 'styles.css']

for filename in files:
    filepath = os.path.join(directory, filename)
    if not os.path.exists(filepath):
        continue
    
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace specific text
    content = re.sub(r'Lemon Squeezy', 'Paddle', content, flags=re.IGNORECASE)
    
    # Clean up trademark
    content = content.replace('Paddle, LLC', 'Paddle.com Market Limited')
    
    # Just in case there are other variations
    content = content.replace('lemonsqueezy', 'paddle')

    with open(filepath, 'w') as f:
        f.write(content)

print("All Lemon Squeezy references updated to Paddle.")
