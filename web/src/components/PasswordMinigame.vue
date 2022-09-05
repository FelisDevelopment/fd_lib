<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" v-if="apps.passwordMinigame">
			<div :class="$style.splash" ref="splashWrapper">
				<div class="fa" :class="$style.hacker">&#xf21b;</div>
				<span class="block font-semibold" ref="splashText">{{ locale.t('input_password_as_shown') }}</span>
			</div>
			<div class="hidden" :class="$style.numbers" ref="numbersWrapper">012345678901</div>
			<div class="hidden" :class="$style.input" ref="inputWrapper">
				<div :class="$style.answer">
					<div :class="$style.answerWrapper">
						<label for="answer">Password</label>
						<input :class="$style.answerInput" type="text" autocomplete="off" autofocus="true" v-model="minigame.entered" @keyup.enter="check()" maxlength="24" ref="input" />
					</div>
				</div>
				<div :class="$style.solution" ref="solutionWrapper"></div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, useCssModule } from 'vue'
import { waitFor } from '../utils'

import { useAxios } from '@vueuse/integrations/useAxios'

import { resource } from '@/utils'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

let numbersWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let splashWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let inputWrapper: HTMLSpanElement = $ref<HTMLSpanElement>()
let input: HTMLInputElement = $ref<HTMLInputElement>()
let solutionWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let splashText: HTMLSpanElement = $ref<HTMLSpanElement>()

function initialData(): { [key: string]: any } {
	return {
		entered: '',
	}
}

let minigame = $ref(initialData())
let data = $ref<{ [key: string]: any }>()

function rangeNumbers(length: number = 1) {
	return Array.from({ length }, (_) => Math.floor(Math.random() * 10))
}

async function check() {
	if (minigame.entered.trim() === minigame.answer.join('')) {
		reset()
		success()

		return
	}

	minigame.answer.map((number: number, pos: number) => {
		let span: HTMLSpanElement = document.createElement('span')

		span.innerText = number.toString()

		if (minigame.entered[pos] !== undefined && minigame.entered[pos] === number.toString()) {
			span.classList.add(classes.good)
		} else {
			span.classList.add(classes.bad)
		}

		solutionWrapper.append(span)
	})

	await waitFor(2000)

	reset()
	failed()
}

async function reset() {
	minigame.gameStarted = false
	clearTimeout(minigame.finishGame)

	minigame = initialData()
}

async function success() {
	splashWrapper.classList.remove('hidden')
	inputWrapper.classList.add('hidden')

	splashText.innerHTML = locale.t('hack_success')
	await waitFor(2000)

	apps.passwordMinigame = false
	useAxios(`https://${resource()}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}

async function failed() {
	splashWrapper.classList.remove('hidden')
	inputWrapper.classList.add('hidden')

	splashText.innerHTML = locale.t('hack_failed')
	await waitFor(2000)

	apps.passwordMinigame = false
	useAxios(`https://${resource()}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

async function start() {
	minigame = initialData()

	apps.passwordMinigame = true

	await waitFor(100)
	splashText.innerHTML = locale.t('input_password_as_shown')

	minigame.answer = rangeNumbers(data.length)
	numbersWrapper.innerHTML = minigame.answer.join('')

	await waitFor(3000)
	splashWrapper.classList.add('hidden')
	numbersWrapper.classList.remove('hidden')

	await waitFor(3000)
	numbersWrapper.classList.add('hidden')
	inputWrapper.classList.remove('hidden')
	input.focus()

	minigame.gameStarted = true

	minigame.finishGame = setTimeout(() => {
		minigame.gameStarted = false
		check()
	}, data.duration)
}

emitter.on('passwordMinigame:open', (event: any) => {
	data = event

	start()
})

emitter.on('passwordMinigame:close', (event: any) => {
	apps.passwordMinigame = false
	reset()
})
</script>
<style module>
.minigame {
	@apply m-[0_auto_20px] w-[600px] min-w-[600px] max-w-[600px] h-[215px] min-h-[215px] max-h-[215px] bg-base-300/90 rounded-md;
}

.minigame > * {
	@apply box-content before:box-content after:box-content;
}
.splash {
	@apply inline-block w-full m-[48px_auto] text-center text-base-content text-[16px];
}
.splash .hacker {
	@apply text-[65px] mb-[30px];
}
.minigame .numbers {
	@apply p-[80px_0] text-center text-base-content text-[44px] select-none;
}
.answer {
	@apply text-center text-[20px] font-semibold text-base-content pt-[70px];
}
.answer label {
	@apply block text-[12px] text-left mb-[8px];
}
.answerWrapper {
	@apply box-content before:box-content after:box-content inline-block relative w-[222px] text-base-content;
}
.answerWrapper:after {
	font-family: 'Font Awesome 5 Free', sans-serif;
	content: '\f21b';
	@apply absolute left-[3px] text-[18px] top-[25px];
}
.answerWrapper.wrong:before {
	font-family: 'Font Awesome 5 Free', sans-serif;
	content: '\f057';
	@apply absolute right-[-25px] bottom-[5px] text-[18px] text-error;
}
.answerWrapper.right:before {
	font-family: 'Font Awesome 5 Free', sans-serif;
	content: '\f058';
	@apply absolute right-[-25px] bottom-[5px] text-[18px] text-success;
}
.answerInput {
	@apply bg-transparent border-b-[2px] border-base-content p-[0_0_6px_28px] w-full text-[16px] font-bold text-base-content;
}
.answerWrapper.wrong #answer {
	@apply border-b-error;
}
.answerWrapper.right #answer {
	@apply border-b-success;
}
.answerInput::placeholder {
	@apply text-base-content/60;
}
.answerInput:focus {
	@apply outline-none;
}
.solution {
	@apply text-[16px] font-semibold text-base-content w-[222px] m-[10px_auto_0] pl-[57px];
}

.solution .good {
	@apply text-success;
}
.solution .bad {
	@apply text-error;
}
</style>
