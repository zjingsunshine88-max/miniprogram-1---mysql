<template>
  <div class="activation-code-management">
    <!-- 搜索和操作栏 -->
    <el-card class="search-card">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-input
            v-model="searchForm.search"
            placeholder="搜索激活码名称或代码"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch">搜索</el-button>
            </template>
          </el-input>
        </el-col>
        <el-col :span="4">
          <el-select v-model="searchForm.status" placeholder="状态筛选" clearable @change="handleSearch">
            <el-option label="全部" value="" />
            <el-option label="有效" value="active" />
            <el-option label="无效" value="inactive" />
            <el-option label="已使用" value="used" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-button type="primary" @click="showCreateDialog = true">
            <el-icon><Plus /></el-icon>
            创建激活码
          </el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 激活码列表 -->
    <el-card class="table-card">
      <el-table
        v-loading="loading"
        :data="activationCodes"
        border
        style="width: 100%"
      >
        <el-table-column prop="code" label="激活码" width="120" />
        <el-table-column prop="name" label="名称" width="150" show-overflow-tooltip />
        <el-table-column prop="description" label="描述" width="200" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusTagType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="user" label="绑定用户" width="120">
          <template #default="scope">
            <span v-if="scope.row.user">{{ scope.row.user.phone_number || scope.row.user.email }}</span>
            <span v-else class="text-gray">未绑定</span>
          </template>
        </el-table-column>
        <el-table-column prop="subjects" label="包含科目" width="200">
          <template #default="scope">
            <el-tag
              v-for="subject in scope.row.subjects"
              :key="subject.id"
              size="small"
              style="margin-right: 5px; margin-bottom: 5px;"
            >
              {{ subject.questionBank.name }} - {{ subject.name }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="expiresAt" label="过期时间" width="150">
          <template #default="scope">
            <span v-if="scope.row.expiresAt">{{ formatDate(scope.row.expiresAt) }}</span>
            <span v-else class="text-gray">永不过期</span>
          </template>
        </el-table-column>
        <el-table-column prop="usedAt" label="使用时间" width="150">
          <template #default="scope">
            <span v-if="scope.row.usedAt">{{ formatDate(scope.row.usedAt) }}</span>
            <span v-else class="text-gray">未使用</span>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="150">
          <template #default="scope">
            {{ formatDate(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button type="primary" size="small" @click="editActivationCode(scope.row)">
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="deleteActivationCode(scope.row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.limit"
        :page-sizes="[10, 20, 50, 100]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; text-align: right;"
      />
    </el-card>

    <!-- 创建/编辑激活码对话框 -->
    <el-dialog
      v-model="showCreateDialog"
      :title="editingCode ? '编辑激活码' : '创建激活码'"
      width="800px"
      @close="resetForm"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="120px">
        <el-form-item label="激活码名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入激活码名称" />
        </el-form-item>
        
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入激活码描述"
          />
        </el-form-item>

        <el-form-item label="包含科目" prop="subjectIds">
          <div class="subject-selection">
            <el-row :gutter="20">
              <el-col :span="8">
                <el-select
                  v-model="selectedQuestionBank"
                  placeholder="选择题库"
                  @change="onQuestionBankChange"
                  style="width: 100%"
                >
                  <el-option
                    v-for="bank in questionBanks"
                    :key="bank.id"
                    :label="bank.name"
                    :value="bank.id"
                  />
                </el-select>
              </el-col>
              <el-col :span="8">
                <el-select
                  v-model="selectedSubject"
                  placeholder="选择科目"
                  @change="addSubject"
                  style="width: 100%"
                  :disabled="!selectedQuestionBank"
                >
                  <el-option
                    v-for="subject in availableSubjects"
                    :key="subject.id"
                    :label="subject.name"
                    :value="subject.id"
                  />
                </el-select>
              </el-col>
              <el-col :span="8">
                <el-button type="primary" @click="addSubject" :disabled="!selectedSubject">
                  添加科目
                </el-button>
              </el-col>
            </el-row>
            
            <div class="selected-subjects" style="margin-top: 15px;">
              <h4>已选择的科目：</h4>
              <el-tag
                v-for="subject in selectedSubjects"
                :key="subject.id"
                closable
                @close="removeSubject(subject.id)"
                style="margin-right: 10px; margin-bottom: 10px;"
              >
                {{ subject.questionBank.name }} - {{ subject.name }}
              </el-tag>
            </div>
          </div>
        </el-form-item>

        <el-form-item label="过期时间">
          <el-date-picker
            v-model="formData.expiresAt"
            type="datetime"
            placeholder="选择过期时间（可选）"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="submitForm" :loading="submitting">
          {{ editingCode ? '更新' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { activationCodeAPI } from '../api/activationCode'
import { questionBankAPI } from '../api/questionBank'
import { subjectAPI } from '../api/subject'

// 响应式数据
const loading = ref(false)
const submitting = ref(false)
const showCreateDialog = ref(false)
const editingCode = ref(null)

const searchForm = reactive({
  search: '',
  status: ''
})

const pagination = reactive({
  page: 1,
  limit: 10,
  total: 0
})

const activationCodes = ref([])
const questionBanks = ref([])
const availableSubjects = ref([])
const selectedQuestionBank = ref('')
const selectedSubject = ref('')
const selectedSubjects = ref([])
const formRef = ref(null)

const formData = reactive({
  name: '',
  description: '',
  subjectIds: [],
  expiresAt: null
})

const formRules = {
  name: [
    { required: true, message: '请输入激活码名称', trigger: 'blur' }
  ],
  subjectIds: [
    { required: true, message: '请至少选择一个科目', trigger: 'change' }
  ]
}

// 生命周期
onMounted(() => {
  loadActivationCodes()
  loadQuestionBanks()
})

// 方法
const loadActivationCodes = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      limit: pagination.limit,
      ...searchForm
    }
    
    // 移除空值
    Object.keys(params).forEach(key => {
      if (params[key] === '') {
        delete params[key]
      }
    })

    const response = await activationCodeAPI.getActivationCodes(params)
    
    if (response.code === 200) {
      activationCodes.value = response.data.list || []
      pagination.total = response.data.total || 0
    } else {
      ElMessage.error(response.message || '获取激活码列表失败')
    }
  } catch (error) {
    console.error('加载激活码列表失败:', error)
    ElMessage.error('加载激活码列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const loadQuestionBanks = async () => {
  try {
    const response = await questionBankAPI.getQuestionBanks()
    if (response.code === 200) {
      questionBanks.value = response.data.list || []
    }
  } catch (error) {
    console.error('加载题库列表失败:', error)
  }
}

const loadSubjects = async (questionBankId) => {
  try {
    const response = await subjectAPI.getSubjects({ questionBankId })
    if (response.code === 200) {
      availableSubjects.value = response.data.list || []
    }
  } catch (error) {
    console.error('加载科目列表失败:', error)
  }
}

const onQuestionBankChange = (questionBankId) => {
  selectedSubject.value = ''
  availableSubjects.value = []
  if (questionBankId) {
    loadSubjects(questionBankId)
  }
}

const addSubject = () => {
  if (!selectedSubject.value) return
  
  const subject = availableSubjects.value.find(s => s.id === selectedSubject.value)
  if (subject && !selectedSubjects.value.find(s => s.id === subject.id)) {
    selectedSubjects.value.push(subject)
    formData.subjectIds = selectedSubjects.value.map(s => s.id)
  }
  
  selectedSubject.value = ''
}

const removeSubject = (subjectId) => {
  selectedSubjects.value = selectedSubjects.value.filter(s => s.id !== subjectId)
  formData.subjectIds = selectedSubjects.value.map(s => s.id)
}

const handleSearch = () => {
  pagination.page = 1
  loadActivationCodes()
}

const handleSizeChange = (size) => {
  pagination.limit = size
  pagination.page = 1
  loadActivationCodes()
}

const handleCurrentChange = (page) => {
  pagination.page = page
  loadActivationCodes()
}

const editActivationCode = (code) => {
  editingCode.value = code
  formData.name = code.name
  formData.description = code.description
  formData.expiresAt = code.expiresAt ? new Date(code.expiresAt) : null
  formData.subjectIds = code.subjects.map(s => s.id)
  selectedSubjects.value = code.subjects
  
  showCreateDialog.value = true
}

const deleteActivationCode = async (code) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除激活码"${code.name}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await activationCodeAPI.deleteActivationCode(code.id)
    
    if (response.code === 200) {
      ElMessage.success('删除成功')
      loadActivationCodes()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除激活码失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    submitting.value = true
    
    const data = {
      name: formData.name,
      description: formData.description,
      subjectIds: formData.subjectIds,
      expiresAt: formData.expiresAt
    }
    
    let response
    if (editingCode.value) {
      response = await activationCodeAPI.updateActivationCode(editingCode.value.id, data)
    } else {
      response = await activationCodeAPI.createActivationCode(data)
    }
    
    if (response.code === 200) {
      ElMessage.success(editingCode.value ? '更新成功' : '创建成功')
      showCreateDialog.value = false
      loadActivationCodes()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    console.error('提交表单失败:', error)
    ElMessage.error('操作失败: ' + error.message)
  } finally {
    submitting.value = false
  }
}

const resetForm = () => {
  editingCode.value = null
  formData.name = ''
  formData.description = ''
  formData.subjectIds = []
  formData.expiresAt = null
  selectedQuestionBank.value = ''
  selectedSubject.value = ''
  selectedSubjects.value = []
  availableSubjects.value = []
}

// 工具函数
const getStatusTagType = (status) => {
  const typeMap = {
    'active': 'success',
    'inactive': 'info',
    'used': 'warning'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status) => {
  const textMap = {
    'active': '有效',
    'inactive': '无效',
    'used': '已使用'
  }
  return textMap[status] || '未知'
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN')
}
</script>

<style scoped>
.activation-code-management {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 20px;
}

.subject-selection {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 15px;
}

.selected-subjects h4 {
  margin: 0 0 10px 0;
  color: #606266;
  font-size: 14px;
}

.text-gray {
  color: #909399;
}
</style>
