<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" v-if="apps.var">
			<div :class="$style.splash" class="" ref="splashWrapper">
				<div class="fa" :class="$style.hacker">&#xf21b;</div>
				<span :class="$style.message" class="block" ref="message">Finger Print Not Recognized</span>
			</div>
			<div :class="$style.groups" class="hidden" ref="groupsWrapper">
				<div v-for="group in minigame.groups" :key="group.id" :class="group.class" :style="group.style" :id="group.id" @click="handleClick(group.index)" :data-number="group.index">
					{{ group.index }}
				</div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, useCssModule } from 'vue'
import { waitFor, random, shuffle, range } from '../utils'
//@ts-ignore-next-line
import mojs from '@mojs/core'

import { useAxios } from '@vueuse/integrations/useAxios'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

const resource: string | undefined = inject('resource')

function initialData() {
	return {
		gameStarted: false,
		order: 1,
		groups: [],
	}
}

let splashWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let groupsWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let message: HTMLSpanElement = $ref<HTMLSpanElement>()

let minigame = $ref<{ [key: string]: any }>(initialData())
let data = $ref<{ [key: string]: any }>()

async function failed() {
	clearTimeout(minigame.gameTimeout)

	minigame.gamePlaying = false
	minigame.gameStarted = false

	await waitFor(500)
	message.innerText = locale.t('system_didnt_accept_answer')
	reset()

	await waitFor(2000)

	apps.var = false
	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

async function success() {
	clearTimeout(minigame.gameTimeout)

	minigame.gamePlaying = false
	minigame.gameStarted = false

	await waitFor(500)
	message.innerText = locale.t('system_bypassed')
	reset()

	await waitFor(2000)

	apps.var = false
	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}

function reset() {
	groupsWrapper.classList.add('hidden')
	groupsWrapper.classList.remove(classes.playing)
	splashWrapper.classList.remove('hidden')
}

function handleClick(number: any) {
	if (!minigame.gamePlaying) return

	if (parseInt(number, 10) === minigame.order) {
		document.getElementById(`el-${number}`)?.classList.add(classes.good)

		minigame.order++

		if (minigame.order > data.numbers) {
			success()
		}

		return
	}

	failed()

	groupsWrapper.classList.remove(classes.playing)
	document.getElementById(`el-${number}`)?.classList.add(classes.bad)
}

function newPos(element: HTMLDivElement) {
	let top = element.offsetTop
	let left = element.offsetLeft
	let new_top = random(10, 755)
	let new_left = random(10, 1420)
	let diff_top = new_top - top
	let diff_left = new_left - left
	let duration = random(10, 40) * 100

	new mojs.Html({
		el: `#${element.id}`,
		x: {
			0: diff_left,
			duration: duration,
			easing: 'linear.none',
		},
		y: {
			0: diff_top,
			duration: duration,
			easing: 'linear.none',
		},
		duration: duration + 50,
		onComplete() {
			if (element.offsetTop === 0 && element.offsetLeft === 0) {
				this.pause()
				return
			}
			element.style.top = `${new_top}px`
			element.style.left = `${new_left}px`
			element.style.transform = 'none'
			newPos(element)
		},
		onUpdate() {
			if (minigame.gameStarted === false) this.pause()
		},
	}).play()
}

async function start() {
	apps.var = true

	await waitFor(100)
	message.innerText = locale.t('finger_print_not_recognized')
	minigame = initialData()

	minigame.gameStarted = true

	await waitFor(3000)
	splashWrapper.classList.add('hidden')

	await waitFor(1000)
	groupsWrapper.classList.remove('hidden')

	await waitFor(500)
	let nums = shuffle(range(1, data.numbers))

	await Promise.all(
		nums.map((num) => {
			let group: { [key: string]: any } = {}

			group.index = num
			group.id = `el-${num}`
			group.style = {
				top: `${random(10, 755)}px`,
				left: `${random(10, 1420)}px`,
			}
			group.class = [classes.group, classes[`bg${random(1, 9)}`]]

			minigame.groups.push(group)
		})
	)

	minigame.groups.forEach((group: any) => {
		const element: HTMLDivElement = document.getElementById(`el-${group.index}`) as HTMLDivElement

		newPos(element)
	})

	await waitFor(data.preparationTime)
	groupsWrapper.classList.add(classes.playing)
	minigame.gamePlaying = true

	minigame.gameTimeout = setTimeout(() => {
		failed()
	}, data.timeout)
}

emitter.on('var:open', (event: any) => {
	data = event

	start()
})

emitter.on('var:close', (event: any) => {
	apps.var = false

	failed()
})
</script>
<style module>
.splash {
	@apply m-[352px_auto] inline-block w-full text-center text-[16px] text-base-content;
}
.splash .hacker {
	@apply mb-[30px] text-[64px];
}
.splash .message {
	@apply text-[24px];
}

.minigame {
	@apply relative m-[0_auto_20px] h-[865px] max-h-[865px] min-h-[865px] w-[1536px] min-w-[1536px] max-w-[1536px] rounded-md bg-base-300/90;
}
.groups {
	@apply relative select-none;
}
.group {
	@apply absolute h-[96px] w-[96px] cursor-pointer rounded-md border-[1px] border-neutral-focus bg-neutral text-center text-[62px] leading-[100px] text-neutral-content;
}
.groups.playing .group {
	@apply text-transparent;
}

.group.bg1 {
	@apply bg-[#00ffff];
}
.group.bg2 {
	@apply bg-[#088f90];
}
.group.bg3 {
	@apply bg-[#708fae];
}
.group.bg4 {
	@apply bg-[#7392b2];
}
.group.bg5 {
	@apply bg-[#6394ed];
}
.group.bg6 {
	@apply bg-[#10487f];
}
.group.bg7 {
	@apply bg-[#0047ab];
}
.group.bg8 {
	@apply bg-[#1335a3];
}
.group.bg9 {
	@apply bg-[#00018b];
}

.group.good {
	@apply border-none bg-success;
	/* #3a5c81 */
}
.group.bad {
	@apply border-none bg-error;
	/* #802525 */
}
</style>
