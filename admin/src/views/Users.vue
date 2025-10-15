<template>
  <div class="users-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="handleAddUser">
            <el-icon><Plus /></el-icon>
            添加用户
          </el-button>
        </div>
      </template>

      <!-- 搜索和筛选 -->
      <div class="search-section">
        <el-row :gutter="20">
          <el-col :span="6">
            <el-input
              v-model="searchForm.keyword"
              placeholder="搜索用户名、手机号或邮箱"
              clearable
              @clear="handleSearch"
              @keyup.enter="handleSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-col>
          <el-col :span="4">
            <el-select v-model="searchForm.status" placeholder="用户状态" clearable @change="handleSearch">
              <el-option label="全部" value="" />
              <el-option label="正常" value="active" />
              <el-option label="禁用" value="inactive" />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-select v-model="searchForm.isAdmin" placeholder="用户类型" clearable @change="handleSearch">
              <el-option label="全部" value="" />
              <el-option label="管理员" value="true" />
              <el-option label="普通用户" value="false" />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-button type="primary" @click="handleSearch">
              <el-icon><Search /></el-icon>
              搜索
            </el-button>
            <el-button @click="handleReset">
              <el-icon><Refresh /></el-icon>
              重置
            </el-button>
          </el-col>
        </el-row>
      </div>

      <!-- 用户列表 -->
      <el-table
        v-loading="loading"
        :data="userList"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="nickName" label="用户名" min-width="120">
          <template #default="{ row }">
            {{ row.nickName || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="手机号" width="130">
          <template #default="{ row }">
            {{ row.phoneNumber || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="邮箱" min-width="180">
          <template #default="{ row }">
            {{ row.email || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="用户类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isAdmin ? 'danger' : 'success'">
              {{ row.isAdmin ? '管理员' : '普通用户' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
              {{ row.status === 'active' ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginTime" label="最后登录" width="160">
          <template #default="{ row }">
            {{ row.lastLoginTime ? formatDate(row.lastLoginTime) : '从未登录' }}
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="160">
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="handleResetPassword(row)">重置密码</el-button>
            <el-dropdown @command="(command) => handleMoreAction(command, row)">
              <el-button size="small">
                更多操作<el-icon class="el-icon--right"><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item :command="'toggleStatus'">
                    <el-icon><Switch /></el-icon>
                    {{ row.status === 'active' ? '禁用用户' : '启用用户' }}
                  </el-dropdown-item>
                  <el-dropdown-item :command="'delete'" divided>
                    <el-icon style="color: var(--el-color-danger)"><Delete /></el-icon>
                    <span style="color: var(--el-color-danger)">删除用户</span>
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.limit"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 添加/编辑用户对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogMode === 'add' ? '添加用户' : '编辑用户'"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userFormRules"
        label-width="100px"
      >
        <el-form-item label="用户昵称" prop="nickName">
          <el-input
            v-model="userForm.nickName"
            placeholder="请输入用户昵称"
            clearable
          />
        </el-form-item>
        <el-form-item label="手机号" prop="phoneNumber">
          <el-input
            v-model="userForm.phoneNumber"
            placeholder="请输入手机号"
            clearable
            maxlength="11"
          />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input
            v-model="userForm.email"
            placeholder="请输入邮箱地址"
            clearable
          />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="userForm.password"
            type="password"
            :placeholder="dialogMode === 'add' ? '请输入密码（可选）' : '留空则不修改密码'"
            clearable
            show-password
          />
        </el-form-item>
        <el-form-item label="用户类型" prop="isAdmin">
          <el-radio-group v-model="userForm.isAdmin">
            <el-radio :label="false">普通用户</el-radio>
            <el-radio :label="true">管理员</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="用户状态" prop="status">
          <el-radio-group v-model="userForm.status">
            <el-radio label="active">正常</el-radio>
            <el-radio label="inactive">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
            确定
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Search, Refresh, ArrowDown, Switch, Delete } from '@element-plus/icons-vue'
import { getUserList, createUser, updateUser, deleteUser, resetUserPassword } from '@/api/user'

// 响应式数据
const loading = ref(false)
const userList = ref([])
const dialogVisible = ref(false)
const dialogMode = ref('add') // 'add' 或 'edit'
const submitLoading = ref(false)
const userFormRef = ref(null)

// 搜索表单
const searchForm = reactive({
  keyword: '',
  status: '',
  isAdmin: ''
})

// 分页信息
const pagination = reactive({
  page: 1,
  limit: 10,
  total: 0
})

// 用户表单
const userForm = reactive({
  id: null,
  nickName: '',
  phoneNumber: '',
  email: '',
  password: '',
  isAdmin: false,
  status: 'active'
})

// 表单验证规则
const userFormRules = {
  nickName: [
    { required: true, message: '请输入用户昵称', trigger: 'blur' },
    { min: 2, max: 20, message: '昵称长度应在 2-20 个字符之间', trigger: 'blur' }
  ],
  phoneNumber: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  password: [
    { min: 6, max: 20, message: '密码长度应在 6-20 个字符之间', trigger: 'blur' }
  ]
}

// 方法
const loadUserList = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      limit: pagination.limit,
      ...searchForm
    }
    console.log('加载用户列表，参数:', params)
    const response = await getUserList(params)
    console.log('用户列表响应:', response)
    console.log('用户数据示例:', response.data.users[0])
    userList.value = response.data.users
    pagination.total = response.data.pagination.total
  } catch (error) {
    console.error('获取用户列表失败:', error)
    ElMessage.error('获取用户列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadUserList()
}

const handleReset = () => {
  Object.assign(searchForm, {
    keyword: '',
    status: '',
    isAdmin: ''
  })
  handleSearch()
}

const handleSizeChange = (val) => {
  pagination.limit = val
  pagination.page = 1
  loadUserList()
}

const handleCurrentChange = (val) => {
  pagination.page = val
  loadUserList()
}

const handleAddUser = () => {
  dialogMode.value = 'add'
  resetForm()
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogMode.value = 'edit'
  // 填充表单数据
  Object.assign(userForm, {
    id: row.id,
    nickName: row.nickName || '',
    phoneNumber: row.phoneNumber || '',
    email: row.email || '',
    password: '', // 编辑时不显示原密码
    isAdmin: row.isAdmin || false,
    status: row.status || 'active'
  })
  dialogVisible.value = true
}

const handleResetPassword = async (row) => {
  try {
    const { value: newPassword } = await ElMessageBox.prompt('请输入新密码（留空则重置为 123456）', '重置密码', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputPattern: /.*/,
      inputPlaceholder: '请输入新密码'
    })
    
    const password = newPassword || '123456'
    
    const response = await resetUserPassword(row.id, password)
    console.log('重置密码响应:', response)
    
    if (response.code === 200) {
      ElMessage.success(`密码重置成功，新密码为: ${response.data.newPassword}`)
    } else {
      ElMessage.error(response.message || '重置密码失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重置密码失败:', error)
      ElMessage.error(error.message || '重置密码失败')
    }
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除用户 "${row.nickName}" 吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )
    
    const response = await deleteUser(row.id)
    console.log('删除用户响应:', response)
    
    if (response.code === 200) {
      ElMessage.success('用户删除成功')
      // 刷新列表
      loadUserList()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除用户失败:', error)
      ElMessage.error(error.message || '删除用户失败')
    }
  }
}

const toggleUserStatus = async (row) => {
  const newStatus = row.status === 'active' ? 'inactive' : 'active'
  const actionText = newStatus === 'active' ? '启用' : '禁用'
  
  try {
    await ElMessageBox.confirm(
      `确定要${actionText}用户 "${row.nickName}" 吗？`,
      '状态变更确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const response = await updateUser(row.id, { status: newStatus })
    console.log('切换用户状态响应:', response)
    
    if (response.code === 200) {
      ElMessage.success(`用户已${actionText}`)
      // 刷新列表
      loadUserList()
    } else {
      ElMessage.error(response.message || `${actionText}失败`)
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('切换用户状态失败:', error)
      ElMessage.error(error.message || '操作失败')
    }
  }
}

const handleMoreAction = (command, row) => {
  switch (command) {
    case 'toggleStatus':
      toggleUserStatus(row)
      break
    case 'delete':
      handleDelete(row)
      break
    default:
      break
  }
}

const handleCloseDialog = () => {
  dialogVisible.value = false
  resetForm()
}

const resetForm = () => {
  if (userFormRef.value) {
    userFormRef.value.resetFields()
  }
  Object.assign(userForm, {
    id: null,
    nickName: '',
    phoneNumber: '',
    email: '',
    password: '',
    isAdmin: false,
    status: 'active'
  })
}

const handleSubmit = async () => {
  if (!userFormRef.value) return
  
  try {
    // 验证表单
    await userFormRef.value.validate()
    
    submitLoading.value = true
    
    if (dialogMode.value === 'add') {
      // 添加用户
      console.log('创建用户，数据:', userForm)
      const response = await createUser(userForm)
      console.log('创建用户响应:', response)
      if (response.code === 200) {
        ElMessage.success('用户创建成功')
        dialogVisible.value = false
        resetForm()
        // 刷新列表
        loadUserList()
      } else {
        ElMessage.error(response.message || '创建失败')
      }
    } else {
      // 编辑用户
      const { id, ...updateData } = userForm
      // 如果密码为空，不更新密码
      if (!updateData.password) {
        delete updateData.password
      }
      console.log('更新用户，ID:', id, '数据:', updateData)
      const response = await updateUser(id, updateData)
      console.log('更新用户响应:', response)
      if (response.code === 200) {
        ElMessage.success('用户更新成功')
        dialogVisible.value = false
        resetForm()
        // 刷新列表
        loadUserList()
      } else {
        ElMessage.error(response.message || '更新失败')
      }
    }
  } catch (error) {
    console.error('提交表单失败:', error)
    if (error !== false) { // 忽略表单验证失败的错误
      ElMessage.error(error.message || '操作失败')
    }
  } finally {
    submitLoading.value = false
  }
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN')
}

// 生命周期
onMounted(() => {
  console.log('用户管理页面已挂载')
  loadUserList()
})
</script>

<style scoped>
.users-page {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-section {
  margin-bottom: 20px;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>