<template>
  <div class="users-page">
    <el-card>
      <template #header>
        <span>用户管理</span>
      </template>
      <div class="placeholder">
        <el-empty description="用户管理页面开发中..." />
      </div>
    </el-card>
  </div>
</template>

<script setup>
// 用户管理页面
</script>

<style scoped>
.users-page {
  padding: 20px;
}

.placeholder {
  height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style> 