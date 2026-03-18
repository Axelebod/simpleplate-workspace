import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import json
from datetime import datetime

# iCloud SMTP settings
SMTP_SERVER = "smtp.mail.me.com"
SMTP_PORT = 587
SMTP_USER = "baudoinaxel83310@icloud.com"  # Compte iCloud pour auth
FROM_EMAIL = "axel@simpleplate.dev"  # Email affiché (domaine perso)
APP_PASSWORD = "oqev-mzah-xuqz-hqpa"  # Mot de passe d'application

def send_email(to_email, subject, body, to_name=""):
    """Send email via iCloud SMTP with custom domain"""
    try:
        # Create message
        msg = MIMEMultipart()
        msg['From'] = f"Axel - SimplePlate <{FROM_EMAIL}>"
        msg['To'] = f"{to_name} <{to_email}>" if to_name else to_email
        msg['Subject'] = subject
        
        # Attach body
        msg.attach(MIMEText(body, 'plain', 'utf-8'))
        
        # Connect to server
        context = ssl.create_default_context()
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls(context=context)
            server.login(SMTP_USER, APP_PASSWORD)
            server.send_message(msg)
        
        return True, "Email sent successfully"
    except Exception as e:
        return False, str(e)

def send_all_messages():
    """Send all draft messages"""
    # Load messages
    with open('/root/.openclaw/workspace/dashboard/data/hunter/messages.json', 'r') as f:
        data = json.load(f)
    
    sent_count = 0
    failed_count = 0
    
    for msg in data['messages']:
        if msg['status'] == 'draft':
            success, result = send_email(
                to_email=msg['email'],
                to_name=msg['leadNom'],
                subject=f"Votre site web {msg['leadNom']}",
                body=msg['message']
            )
            
            if success:
                msg['status'] = 'sent'
                msg['sentDate'] = datetime.now().isoformat()
                sent_count += 1
                print(f"✅ Sent to {msg['leadNom']} ({msg['email']})")
            else:
                failed_count += 1
                print(f"❌ Failed to {msg['leadNom']}: {result}")
    
    # Update stats
    data['messagesByStatus']['sent'] = sent_count
    data['messagesByStatus']['draft'] = len(data['messages']) - sent_count
    data['lastUpdated'] = datetime.now().isoformat()
    
    # Save back
    with open('/root/.openclaw/workspace/dashboard/data/hunter/messages.json', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"\n📊 Summary: {sent_count} sent, {failed_count} failed")
    return sent_count, failed_count

def check_responses():
    """Check for replies to sent messages"""
    try:
        import imaplib
        
        # Connect to iCloud IMAP
        IMAP_SERVER = "imap.mail.me.com"
        
        mail = imaplib.IMAP4_SSL(IMAP_SERVER)
        mail.login(SMTP_USER, APP_PASSWORD)
        mail.select('inbox')
        
        # Search for unread emails
        status, messages = mail.search(None, 'UNSEEN')
        
        if messages[0]:
            message_ids = messages[0].split()
            print(f"📩 {len(message_ids)} new emails found")
            
            # Check each email
            for msg_id in message_ids:
                status, msg_data = mail.fetch(msg_id, '(RFC822)')
                from email import message_from_bytes
                email_msg = message_from_bytes(msg_data[0][1])
                
                subject = email_msg['Subject']
                sender = email_msg['From']
                
                print(f"New email from {sender}: {subject}")
                
        mail.close()
        mail.logout()
        
    except Exception as e:
        print(f"Error checking responses: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "check":
        print("🔍 Checking for responses...")
        check_responses()
    else:
        print("🚀 Starting email campaign...")
        print(f"From: {FROM_EMAIL}")
        print("-" * 50)
        send_all_messages()
