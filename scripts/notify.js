#!/usr/bin/env node
/**
 * Team Communication Utility
 * Usage: node notify.js <from> <to> <type> [message]
 * 
 * Examples:
 *   node notify.js scrapy hunter leads_ready "12 nouveaux leads"
 *   node notify.js hunter all message_sent "6 emails envoyés"
 *   node notify.js wilson jarbite site_ready "Site livré pour Chez Nous"
 */

const fs = require('fs');
const path = require('path');

const NOTIFICATIONS_FILE = '/root/.openclaw/workspace/dashboard/data/notifications.json';
const AGENT_STATUS_FILE = '/root/.openclaw/workspace/dashboard/data/agent-status.json';

function loadJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (e) {
    return { notifications: [], unreadCount: 0 };
  }
}

function saveJson(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

function notify(from, to, type, message, data = {}) {
  const notifications = loadJson(NOTIFICATIONS_FILE);
  
  const notification = {
    id: 'notif-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
    from,
    to,
    type,
    message,
    data,
    timestamp: new Date().toISOString(),
    read: false
  };
  
  notifications.notifications.unshift(notification);
  notifications.unreadCount++;
  notifications.lastUpdate = new Date().toISOString();
  
  saveJson(NOTIFICATIONS_FILE, notifications);
  
  // Update agent status
  const status = loadJson(AGENT_STATUS_FILE);
  if (status.agents && status.agents[from]) {
    status.agents[from].lastActive = new Date().toISOString();
    status.lastUpdate = new Date().toISOString();
    saveJson(AGENT_STATUS_FILE, status);
  }
  
  console.log(`✅ Notification envoyée: ${from} → ${to}`);
  console.log(`   Type: ${type}`);
  console.log(`   Message: ${message}`);
}

function updateStatus(agent, statusUpdate) {
  const status = loadJson(AGENT_STATUS_FILE);
  
  if (!status.agents) status.agents = {};
  if (!status.agents[agent]) {
    status.agents[agent] = {
      status: 'idle',
      currentTask: '',
      progress: 0,
      lastActive: new Date().toISOString()
    };
  }
  
  Object.assign(status.agents[agent], statusUpdate);
  status.agents[agent].lastActive = new Date().toISOString();
  status.lastUpdate = new Date().toISOString();
  
  saveJson(AGENT_STATUS_FILE, status);
  
  console.log(`✅ Statut mis à jour: ${agent}`);
  console.log(`   Status: ${status.agents[agent].status}`);
  console.log(`   Task: ${status.agents[agent].currentTask}`);
}

// CLI
const [,, command, ...args] = process.argv;

if (command === 'notify') {
  const [from, to, type, ...messageParts] = args;
  const message = messageParts.join(' ');
  
  if (!from || !to || !type) {
    console.log('Usage: node notify.js notify <from> <to> <type> [message]');
    process.exit(1);
  }
  
  notify(from, to, type, message || `${from} sent ${type} notification`);
} else if (command === 'status') {
  const [agent, status, task, progress] = args;
  
  if (!agent) {
    console.log('Usage: node notify.js status <agent> <status> [task] [progress]');
    process.exit(1);
  }
  
  updateStatus(agent, {
    status,
    currentTask: task || '',
    progress: parseInt(progress) || 0
  });
} else if (command === 'list') {
  const notifications = loadJson(NOTIFICATIONS_FILE);
  console.log('\n📬 Notifications:');
  console.log('================');
  notifications.notifications.slice(0, 10).forEach(n => {
    const icon = n.read ? '✓' : '●';
    console.log(`${icon} [${n.from} → ${n.to}] ${n.type}: ${n.message}`);
  });
  console.log(`\nTotal: ${notifications.notifications.length}, Unread: ${notifications.unreadCount}\n`);
} else {
  console.log(`
Team Communication Utility

Commands:
  notify <from> <to> <type> [message]  Send notification
  status <agent> <status> [task] [progress]  Update agent status
  list                                  Show recent notifications

Examples:
  node notify.js notify scrapy hunter leads_ready "12 nouveaux leads"
  node notify.js status hunter working "Envoi emails" 50
  node notify.js list
`);
}
