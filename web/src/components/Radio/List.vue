<template>
	<div class="flex flex-col overflow-hidden h-full">
		<div class="flex items-center w-full h-[12%] bg-primary/50 select-none">
			<div class="flex flex-1 items-baseline gap-1 pl-2">
				<i class="fa-solid fa-signal text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] leading-none" v-if="radio.current"></i>
				<i class="fa-solid fa-xmark text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] leading-none" v-if="!radio.current"></i>
				<span class="text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] font-semibold leading-none" v-if="radio.current">{{ radio.current }}</span>
			</div>
			<div class="w-0.5 h-[70%] bg-secondary/40 rounded-full"></div>
			<div class="flex flex-1 items-center justify-end gap-1 pr-2">
				<span class="text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)] font-semibold">{{ radio.volume }}</span>
				<i class="fa-solid fa-volume-high text-[calc(8px_+_0.390625vh)] 2xl:text-[calc(11px_+_0.390625vh)]"></i>
			</div>
		</div>
		<div class="flex flex-col flex-1 overflow-auto scl p-4 gap-4">
			<div class="flex bg-primary/50 w-full rounded-md py-1 px-2 items-center hover:text-primary-content hover:bg-primary gap-3 select-none" @click="radio.setTab('connection')">
				<i class="fa-solid fa-arrow-left text-[calc(10px_+_0.390625vh)]"></i>
				<span class="text-[calc(10px_+_0.390625vh)]">{{ locale.t('back_radio') }}</span>
			</div>
			<div class="flex flex-col w-full rounded-md gap-1 flex-1">
				<div class="w-full px-2 py-1 bg-primary/50 rounded-md flex gap-1 items-baseline" v-for="item in radio.radioList">
					<span class="font-bold flex-shrink-0 text-[calc(10px_+_0.390625vh)]" v-if="item.sign">{{ item.sign }}</span>
					<span class="text-[calc(10px_+_0.390625vh)] break-all" v-if="item.name">{{ item.name }}</span>
				</div>
			</div>
		</div>
	</div>
</template>
<script setup lang="ts">
import { useRadio } from '@/stores/radio'
import { useLocale } from '@/stores/locale'

const radio = useRadio()
const locale = useLocale()
</script>
