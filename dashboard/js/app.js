/**
 * SimplePlate Dashboard v2 - JavaScript commun
 */

// API helpers
const API = {
    async getLeads() {
        try {
            const response = await fetch('../data/leads.json');
            return await response.json();
        } catch (error) {
            console.error('Error loading leads:', error);
            return { leads: [] };
        }
    },

    async getMessages() {
        try {
            const response = await fetch('../data/messages.json');
            return await response.json();
        } catch (error) {
            return { messages: [] };
        }
    },

    async saveMessage(message) {
        // Append to messages
        const data = await this.getMessages();
        data.messages.push({
            ...message,
            id: Date.now(),
            date: new Date().toISOString()
        });
        // In real app, would POST to server
        console.log('Message saved:', message);
    }
};

// UI helpers
const UI = {
    showLoading(elementId) {
        const el = document.getElementById(elementId);
        if (el) {
            el.innerHTML = `
                <div class="loading">
                    <div class="spinner"></div>
                    <p>Chargement...</p>
                </div>
            `;
        }
    },

    showEmpty(elementId, message = 'Aucune donnée') {
        const el = document.getElementById(elementId);
        if (el) {
            el.innerHTML = `
                <div class="empty">
                    <div class="empty-icon">📭</div>
                    <p>${message}</p>
                </div>
            `;
        }
    },

    formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            day: 'numeric',
            month: 'short',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
};

// Navigation
function goBack() {
    window.history.back();
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    // Add back button functionality
    const backButtons = document.querySelectorAll('.back-btn');
    backButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            goBack();
        });
    });
});