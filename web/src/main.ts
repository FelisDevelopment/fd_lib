import { createApp } from 'vue'
import { createPinia } from 'pinia'
import mitt from 'mitt'
import { resource } from './utils'

import App from './App.vue'
import '@/assets/main.css'

// Events Bus
const emitter = mitt()

const app = createApp(App).use(createPinia())
app.provide('emitter', emitter)

app.provide('resource', resource())

app.mount('#felisUi')
