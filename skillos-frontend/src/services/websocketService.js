import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';

let stompClient = null;

const WEBSOCKET_URL = import.meta.env.VITE_API_BASE_URL
  ? import.meta.env.VITE_API_BASE_URL.replace('/api/v1', '/ws')
  : 'http://localhost:8080/ws';

export const wsEvents = new EventTarget();

export const connectWebSocket = () => {
  console.log('[WS DEBUG] connectWebSocket called');
  console.log('[WS DEBUG] WEBSOCKET_URL =', WEBSOCKET_URL);

  // Disconnect any existing connection first
  if (stompClient !== null) {
    console.log('[WS DEBUG] Disconnecting previous stompClient');
    stompClient.deactivate();
    stompClient = null;
  }

  const token = localStorage.getItem('skillos_token');
  console.log('[WS DEBUG] token found =', !!token, token ? token.substring(0, 20) + '...' : 'NULL');
  if (!token) {
    console.error('[WS DEBUG] No token found, aborting WebSocket connection');
    return;
  }

  console.log('[WS DEBUG] Creating SockJS connection to:', WEBSOCKET_URL);
  const socket = new SockJS(WEBSOCKET_URL);

  stompClient = new Client({
    webSocketFactory: () => socket,
    connectHeaders: {
      Authorization: `Bearer ${token}`
    },
    debug: function (str) {
      console.log('[STOMP]', str);
    },
    reconnectDelay: 5000,
    heartbeatIncoming: 4000,
    heartbeatOutgoing: 4000,
  });

  stompClient.onConnect = function (frame) {
    console.log('[WS DEBUG] STOMP connected!', frame);
    stompClient.subscribe('/user/queue/messages', (message) => {
      console.log('[WS DEBUG] Message received:', message.body);
      if (message.body) {
        wsEvents.dispatchEvent(new CustomEvent('ws-message', { detail: JSON.parse(message.body) }));
      }
    });

    stompClient.subscribe('/user/queue/notifications', (message) => {
      console.log('[WS DEBUG] Notification received:', message.body);
      if (message.body) {
        wsEvents.dispatchEvent(new CustomEvent('ws-notification', { detail: JSON.parse(message.body) }));
      }
    });
  };

  stompClient.onStompError = function (frame) {
    console.error('[WS DEBUG] Broker reported error: ' + frame.headers['message']);
    console.error('[WS DEBUG] Additional details: ' + frame.body);
  };

  stompClient.onWebSocketError = function (event) {
    console.error('[WS DEBUG] WebSocket error:', event);
  };

  stompClient.onWebSocketClose = function (event) {
    console.warn('[WS DEBUG] WebSocket closed:', event);
  };

  stompClient.activate();
  console.log('[WS DEBUG] stompClient.activate() called');
};

export const disconnectWebSocket = () => {
  if (stompClient !== null) {
    stompClient.deactivate();
    stompClient = null;
  }
};

export const sendMessage = (receiverId, messageBody) => {
  console.log('[WS DEBUG] sendMessage called, receiverId=', receiverId, 'body=', messageBody);
  console.log('[WS DEBUG] stompClient =', stompClient, 'connected =', stompClient?.connected);
  if (stompClient && stompClient.connected) {
    const payload = JSON.stringify({
      receiverId: receiverId,
      body: messageBody
    });
    console.log('[WS DEBUG] Publishing to /app/chat:', payload);
    stompClient.publish({
      destination: '/app/chat',
      body: payload
    });
  } else {
    console.error("[WS DEBUG] STOMP connection not established. stompClient:", stompClient);
  }
};
