<template>
	<div class="flex flex-shrink-0 justify-between items-center px-2.5 w-full h-10 bg-slate-800 rounded actions-inset">
		<div class="flex flex-col gap-0.5">
			<span class="text-xs text-white">{{ 'Unknown' }}</span>
			<div class="flex gap-3">
				<span class="flex items-center gap-1">
					<i class="fas fa-dollar-sign text-green-500 text-xs"></i>
					<span class="text-white text-[10px]">1,000,000</span>
				</span>
				<span class="flex items-center gap-1">
					<i class="fas fa-coins text-blue-500 text-xs"></i>
					<span class="text-white text-[10px]">500</span>
				</span>
			</div>
		</div>
		<div class="inline-flex items-center gap-1">
			<i class="fas fa-weight-hanging text-green-500 text-xs"></i>
			<span class="text-[10px] text-white">0.0 / 50.0</span>
		</div>
	</div>
</template>
<script setup lang="ts"></script>
