import imaplib
import ssl
import email
from email.header import decode_header
import json
from datetime import datetime, timedelta
import re

# Configuration
IMAP_SERVER = "imap.mail.me.com"
IMAP_PORT = 993
SMTP_USER = "baudoinaxel83310@icloud.com"
APP_PASSWORD = "oqev-mzah-xuqz-hqpa"

# Liste des prospects contactés (emails)
PROSPECTS_FILE = "/root/.openclaw/workspace/dashboard/data/hunter/prospects_contacted.json"

def load_contacted_prospects():
    """Load list of contacted prospects"""
    try:
        with open(PROSPECTS_FILE, 'r') as f:
            return json.load(f)
    except:
        return []

def save_contacted_prospects(prospects):
    """Save list of contacted prospects"""
    with open(PROSPECTS_FILE, 'w') as f:
        json.dump(prospects, f, indent=2)

def check_new_responses():
    """Check inbox for responses from prospects"""
    try:
        # Connect to iCloud IMAP
        mail = imaplib.IMAP4_SSL(IMAP_SERVER)
        mail.login(SMTP_USER, APP_PASSWORD)
        mail.select('inbox')
        
        # Search for unread emails from last 7 days
        date_since = (datetime.now() - timedelta(days=7)).strftime("%d-%b-%Y")
        status, messages = mail.search(None, f'(UNSEEN SINCE {date_since})')
        
        responses = []
        
        if messages[0]:
            message_ids = messages[0].split()
            
            for msg_id in message_ids:
                status, msg_data = mail.fetch(msg_id, '(RFC822)')
                if not msg_data or not msg_data[0]:
                    continue
                raw_email = msg_data[0][1]
                if isinstance(raw_email, int):
                    continue
                email_message = email.message_from_bytes(raw_email)
                
                # Get sender
                from_header = email_message['From']
                sender_email = extract_email(from_header)
                sender_name = extract_name(from_header)
                
                # Get subject
                subject = decode_header_str(email_message['Subject'])
                
                # Get body
                body = get_email_body(email_message)
                
                # Check if sender is in our prospects list
                prospects = load_contacted_prospects()
                
                for prospect in prospects:
                    if prospect['email'].lower() == sender_email.lower():
                        # This is a response from a prospect!
                        response = {
                            "id": f"resp-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
                            "prospectId": prospect['id'],
                            "prospectNom": prospect['nom'],
                            "fromEmail": sender_email,
                            "fromName": sender_name,
                            "subject": subject,
                            "body": body[:500] + "..." if len(body) > 500 else body,
                            "receivedAt": datetime.now().isoformat(),
                            "status": "new"
                        }
                        responses.append(response)
                        
                        # Mark as read in inbox
                        mail.store(msg_id, '+FLAGS', '\\Seen')
                        
                        print(f"📩 NOUVELLE RÉPONSE de {prospect['nom']} ({sender_email})")
                        print(f"   Sujet: {subject}")
                        print(f"   Aperçu: {body[:100]}...")
                        print()
        
        mail.close()
        mail.logout()
        
        # Save responses
        if responses:
            save_responses(responses)
            notify_user(responses)
        
        return responses
        
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")
        import traceback
        traceback.print_exc()
        return []

def extract_email(from_header):
    """Extract email from From header"""
    match = re.search(r'<([^>]+)>', from_header)
    if match:
        return match.group(1)
    # If no angle brackets, assume the whole thing is the email
    return from_header.strip()

def extract_name(from_header):
    """Extract name from From header"""
    match = re.search(r'^([^<]+)<', from_header)
    if match:
        return match.group(1).strip()
    return ""

def decode_header_str(header):
    """Decode email header string"""
    if header is None:
        return ""
    decoded, charset = decode_header(header)[0]
    if isinstance(decoded, bytes):
        return decoded.decode(charset or 'utf-8')
    return decoded

def get_email_body(email_message):
    """Extract body from email message"""
    body = ""
    if email_message.is_multipart():
        for part in email_message.walk():
            content_type = part.get_content_type()
            if content_type == "text/plain":
                try:
                    body = part.get_payload(decode=True).decode('utf-8')
                    break
                except:
                    pass
    else:
        try:
            body = email_message.get_payload(decode=True).decode('utf-8')
        except:
            body = str(email_message.get_payload())
    return body

def save_responses(responses):
    """Save responses to file"""
    try:
        with open('/root/.openclaw/workspace/dashboard/data/hunter/responses.json', 'r') as f:
            data = json.load(f)
    except:
        data = {"responses": []}
    
    data['responses'].extend(responses)
    data['lastChecked'] = datetime.now().isoformat()
    
    with open('/root/.openclaw/workspace/dashboard/data/hunter/responses.json', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def notify_user(responses):
    """Notify user of new responses"""
    print("=" * 60)
    print("🎯 HUNTER - NOUVELLES RÉPONSES DÉTECTÉES")
    print("=" * 60)
    print()
    print(f"Nombre de réponses: {len(responses)}")
    print()
    
    for resp in responses:
        print(f"📧 De: {resp['prospectNom']} ({resp['fromEmail']})")
        print(f"📋 Sujet: {resp['subject']}")
        print(f"📝 Message:\n{resp['body']}")
        print("-" * 60)
    
    print()
    print("Que veux-tu faire ?")
    print("1. Répondre à ce prospect")
    print("2. Marquer comme lu et attendre")
    print("3. Transférer à Wilson pour création du site")
    print()

if __name__ == "__main__":
    print("🔍 Vérification des réponses...")
    print(f"Heure: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 60)
    
    # Load prospects from messages.json
    with open('/root/.openclaw/workspace/dashboard/data/hunter/messages.json', 'r') as f:
        data = json.load(f)
    
    prospects = []
    for msg in data['messages']:
        if msg['status'] == 'sent':
            prospects.append({
                'id': msg['leadId'],
                'nom': msg['leadNom'],
                'email': msg['email']
            })
    
    save_contacted_prospects(prospects)
    
    responses = check_new_responses()
    
    if not responses:
        print("📭 Aucune nouvelle réponse pour le moment.")
    else:
        print(f"✅ {len(responses)} réponse(s) détectée(s)!")
