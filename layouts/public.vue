<template>
  <div class="min-h-screen flex flex-col">
    <PublicNavbar />
    <main class="flex-1">
      <slot />
    </main>
    <AppFooter />
  </div>
</template>
