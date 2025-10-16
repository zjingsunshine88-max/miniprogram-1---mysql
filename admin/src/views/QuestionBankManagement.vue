<template>
  <div class="question-bank-management">
    <!-- 题库列表页面 -->
    <div v-if="!currentQuestionBank" class="bank-list-page">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>题库管理</span>
            <div class="header-actions">
              <el-button type="primary" @click="showCreateDialog = true">
                <el-icon><Plus /></el-icon>
                创建题库
              </el-button>
              <el-button @click="loadQuestionBanks">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>
        </template>

        <!-- 搜索和筛选 -->
        <div class="search-section">
          <el-row :gutter="20">
            <el-col :span="6">
              <el-input
                v-model="searchForm.keyword"
                placeholder="搜索题库名称"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </el-col>
            <el-col :span="4">
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
              <el-button @click="resetSearch">重置</el-button>
            </el-col>
          </el-row>
        </div>

        <!-- 题库列表 -->
        <div class="bank-grid">
          <el-card
            v-for="bank in questionBanks"
            :key="bank.id"
            class="bank-card"
            shadow="hover"
            @click="enterQuestionBank(bank)"
          >
            <div class="bank-info">
              <h3 class="bank-name">{{ bank.name }}</h3>
              <p class="bank-description">{{ bank.description || '暂无描述' }}</p>
              <div class="bank-stats">
                <span class="stat-item">
                  <el-icon><Document /></el-icon>
                  {{ bank.subjectCount || 0 }} 个科目
                </span>
                <span class="stat-item">
                  <el-icon><QuestionFilled /></el-icon>
                  {{ bank.questionCount || 0 }} 道题目
                </span>
                <span class="stat-item">
                  <el-icon><Calendar /></el-icon>
                  {{ formatDate(bank.createdAt) }}
                </span>
              </div>
            </div>
            <div class="bank-actions">
              <el-button size="small" type="primary" @click.stop="enterQuestionBank(bank)">
                进入题库
              </el-button>
              <el-button size="small" @click.stop="editQuestionBank(bank)">
                编辑
              </el-button>
              <el-button size="small" type="danger" @click.stop="deleteQuestionBank(bank)">
                删除
              </el-button>
            </div>
          </el-card>
        </div>

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
    </div>

    <!-- 科目列表页面 -->
    <div v-else-if="!currentSubject" class="subject-list-page">
      <el-card>
        <template #header>
          <div class="card-header">
            <div class="header-left">
              <el-button @click="backToQuestionBanks" type="text">
                <el-icon><ArrowLeft /></el-icon>
                返回题库列表
              </el-button>
              <span class="bank-title">{{ currentQuestionBank.name }}</span>
            </div>
            <div class="header-actions">
              <el-button type="primary" @click="showCreateSubjectDialog = true">
                <el-icon><Plus /></el-icon>
                创建科目
              </el-button>
              <el-button @click="loadSubjects">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>
        </template>

        <!-- 科目列表 -->
        <div class="subject-grid">
          <el-card
            v-for="subject in subjects"
            :key="subject.id"
            class="subject-card"
            shadow="hover"
            @click="enterSubject(subject)"
          >
            <div class="subject-info">
              <h3 class="subject-name">{{ subject.name }}</h3>
              <p class="subject-description">{{ subject.description || '暂无描述' }}</p>
              <div class="subject-stats">
                <span class="stat-item">
                  <el-icon><QuestionFilled /></el-icon>
                  {{ subject.questionCount || 0 }} 道题目
                </span>
                <span class="stat-item">
                  <el-icon><Calendar /></el-icon>
                  {{ formatDate(subject.createdAt) }}
                </span>
              </div>
            </div>
            <div class="subject-actions">
              <el-button size="small" type="primary" @click.stop="enterSubject(subject)">
                进入科目
              </el-button>
              <el-button size="small" @click.stop="editSubject(subject)">
                编辑
              </el-button>
              <el-button size="small" type="danger" @click.stop="deleteSubject(subject)">
                删除
              </el-button>
            </div>
          </el-card>
        </div>
      </el-card>
    </div>

    <!-- 题目列表页面 -->
    <div v-else class="question-list-page">
      <el-card>
        <template #header>
          <div class="card-header">
            <div class="header-left">
              <el-button @click="backToSubjects" type="text">
                <el-icon><ArrowLeft /></el-icon>
                返回科目列表
              </el-button>
              <span class="subject-title">{{ currentSubject.name }}</span>
            </div>
            <div class="header-actions">
              <el-button 
                type="danger" 
                @click="batchDeleteQuestions" 
                :disabled="selectedQuestions.length === 0"
                v-if="selectedQuestions.length > 0"
              >
                <el-icon><Delete /></el-icon>
                批量删除 ({{ selectedQuestions.length }})
              </el-button>
              <el-button type="success" @click="createQuestion">
                <el-icon><Plus /></el-icon>
                添加题目
              </el-button>
              <el-button type="primary" @click="$router.push('/smart-question-import')">
                <el-icon><Upload /></el-icon>
                智能上传
              </el-button>
              <el-button @click="loadQuestions">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>
        </template>

        <!-- 题目列表 -->
        <el-table
          :data="questions"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="getTypeTagType(row.type)">{{ row.type }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="difficulty" label="难度" width="100">
            <template #default="{ row }">
              <el-tag :type="getDifficultyTagType(row.difficulty)">{{ row.difficulty }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="创建时间" width="180">
            <template #default="{ row }">
              {{ formatDate(row.createdAt) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="editQuestion(row)">编辑</el-button>
              <el-button size="small" type="danger" @click="deleteQuestion(row)">删除</el-button>
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
    </div>

    <!-- 创建/编辑题库对话框 -->
    <el-dialog 
      v-model="showCreateDialog" 
      :title="editingBank ? '编辑题库' : '创建题库'" 
      width="500px"
    >
      <el-form :model="createBankForm" label-width="100px">
        <el-form-item label="题库名称" required>
          <el-input v-model="createBankForm.name" placeholder="请输入题库名称" />
        </el-form-item>
        <el-form-item label="题库描述">
          <el-input
            v-model="createBankForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入题库描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelBankEdit">取消</el-button>
        <el-button type="primary" @click="saveQuestionBank">确定</el-button>
      </template>
    </el-dialog>

    <!-- 创建/编辑科目对话框 -->
    <el-dialog 
      v-model="showCreateSubjectDialog" 
      :title="editingSubject ? '编辑科目' : '创建科目'" 
      width="500px"
    >
      <el-form :model="createSubjectForm" label-width="100px">
        <el-form-item label="科目名称" required>
          <el-input v-model="createSubjectForm.name" placeholder="请输入科目名称" />
        </el-form-item>
        <el-form-item label="科目描述">
          <el-input
            v-model="createSubjectForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入科目描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelSubjectEdit">取消</el-button>
        <el-button type="primary" @click="saveSubject">确定</el-button>
      </template>
    </el-dialog>

    <!-- 题目详情/编辑对话框 -->
    <el-dialog
      v-model="showDetailDialog"
      :title="editing ? '编辑题目' : '题目详情'"
      width="900px"
      :close-on-click-modal="false"
    >
      <div v-if="currentQuestion" class="question-detail">
        <!-- 编辑模式 -->
        <div v-if="editing" class="edit-form">
          <el-form :model="editForm" label-width="100px" label-position="left">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="题目ID">
                  <el-input v-model="editForm.id" disabled />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="科目">
                  <el-input v-model="editForm.subject" disabled />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="章节">
                  <el-input v-model="editForm.chapter" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="类型">
                  <el-select v-model="editForm.type" style="width: 100%">
                    <el-option label="单选题" value="单选题" />
                    <el-option label="多选题" value="多选题" />
                    <el-option label="判断题" value="判断题" />
                    <el-option label="填空题" value="填空题" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="难度">
                  <el-select v-model="editForm.difficulty" style="width: 100%">
                    <el-option label="简单" value="简单" />
                    <el-option label="中等" value="中等" />
                    <el-option label="困难" value="困难" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="正确答案">
                  <el-input v-model="editForm.answer" placeholder="如：A、AB、正确等" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="题目内容">
              <el-input
                v-model="editForm.content"
                type="textarea"
                :rows="4"
                placeholder="请输入题目内容"
              />
            </el-form-item>

            <el-form-item label="题目图片">
              <div class="image-upload-section">
                <el-upload
                  ref="questionImageUploadRef"
                  :action="uploadUrl"
                  :headers="uploadHeaders"
                  :on-success="handleQuestionImageSuccess"
                  :on-error="handleQuestionImageError"
                  :on-change="handleQuestionImageChange"
                  :before-upload="beforeQuestionImageUpload"
                  :file-list="editForm.questionImages"
                  list-type="picture-card"
                  :limit="5"
                  accept="image/*"
                >
                  <el-icon><Plus /></el-icon>
                </el-upload>
                <div class="upload-tip">
                  支持上传JPG、PNG格式图片，最多5张
                </div>
              </div>
            </el-form-item>

            <el-form-item label="选项">
              <div class="options-editor">
                <div v-for="(option, index) in editForm.options" :key="index" class="option-item">
                  <el-input
                    v-model="editForm.options[index].content"
                    :placeholder="`选项 ${String.fromCharCode(65 + index)}`"
                  >
                    <template #prepend>{{ String.fromCharCode(65 + index) }}.</template>
                  </el-input>
                  <el-button
                    v-if="editForm.options.length > 2"
                    type="danger"
                    size="small"
                    @click="removeOption(index)"
                  >
                    删除
                  </el-button>
                </div>
                <el-button
                  v-if="editForm.options.length < 6"
                  type="primary"
                  size="small"
                  @click="addOption"
                >
                  添加选项
                </el-button>
              </div>
            </el-form-item>

            <el-form-item label="解析">
              <el-input
                v-model="editForm.analysis"
                type="textarea"
                :rows="3"
                placeholder="请输入题目解析"
              />
            </el-form-item>

            <el-form-item label="解析图片">
              <div class="image-upload-section">
                <el-upload
                  ref="imageUploadRef"
                  :action="uploadUrl"
                  :headers="uploadHeaders"
                  :on-success="handleImageSuccess"
                  :on-error="handleImageError"
                  :on-change="handleImageChange"
                  :before-upload="beforeImageUpload"
                  :file-list="editForm.images"
                  list-type="picture-card"
                  :limit="5"
                  accept="image/*"
                >
                  <el-icon><Plus /></el-icon>
                </el-upload>
                <div class="upload-tip">
                  支持上传JPG、PNG格式图片，最多5张
                </div>
              </div>
            </el-form-item>
          </el-form>
        </div>

        <!-- 查看模式 -->
        <div v-else>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="题目ID">{{ currentQuestion.id }}</el-descriptions-item>
            <el-descriptions-item label="科目">{{ currentQuestion.subject }}</el-descriptions-item>
            <el-descriptions-item label="章节">{{ currentQuestion.chapter }}</el-descriptions-item>
            <el-descriptions-item label="类型">
              <el-tag :type="getTypeTagType(currentQuestion.type)">
                {{ getTypeText(currentQuestion.type) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="难度">
              <el-tag :type="getDifficultyTagType(currentQuestion.difficulty)">
                {{ currentQuestion.difficulty }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="创建时间">
              {{ formatDate(currentQuestion.createdAt) }}
            </el-descriptions-item>
          </el-descriptions>

          <div class="question-content">
            <h4>题目内容：</h4>
            <p>{{ currentQuestion.content }}</p>

            <div v-if="currentQuestion.questionImages && currentQuestion.questionImages.length > 0">
              <h4>题目图片：</h4>
              <div class="images-grid">
                <el-image
                  v-for="(image, index) in getQuestionImagePreviewList()"
                  :key="index"
                  :src="getImageUrl(image.path)"
                  :preview-src-list="getQuestionImagePreviewList().map(img => getImageUrl(img.path))"
                  fit="cover"
                  class="analysis-image"
                />
              </div>
            </div>

            <div v-if="currentQuestion.options && currentQuestion.options.length > 0">
              <h4>选项：</h4>
              <ul>
                <li v-for="(option, index) in currentQuestion.options" :key="index">
                  {{ String.fromCharCode(65 + index) }}. {{ option.content || option }}
                </li>
              </ul>
            </div>

            <div class="answer-section">
              <h4>正确答案：</h4>
              <p class="answer">{{ currentQuestion.answer }}</p>
            </div>

            <div v-if="currentQuestion.analysis">
              <h4>解析：</h4>
              <p>{{ currentQuestion.analysis }}</p>
            </div>

            <div v-if="currentQuestion.images && currentQuestion.images.length > 0">
              <h4>解析图片：</h4>
              <div class="images-grid">
                <el-image
                  v-for="(image, index) in getValidImages()"
                  :key="index"
                  :src="getImageUrl(image.path)"
                  :preview-src-list="getImagePreviewList()"
                  fit="cover"
                  class="analysis-image"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showDetailDialog = false">取消</el-button>
          <el-button v-if="editing" type="primary" :loading="saving" @click="saveQuestion">
            保存
          </el-button>
          <el-button v-else type="primary" @click="startEdit">编辑</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 创建题目对话框 -->
    <el-dialog
      v-model="showCreateQuestionDialog"
      title="创建题目"
      width="800px"
      :close-on-click-modal="false"
    >
      <el-form :model="createForm" label-width="100px" ref="createFormRef">
        <el-form-item label="题目内容" prop="content" :rules="[{ required: true, message: '请输入题目内容', trigger: 'blur' }]">
          <el-input
            v-model="createForm.content"
            type="textarea"
            :rows="3"
            placeholder="请输入题目内容"
          />
        </el-form-item>

        <el-form-item label="题目类型" prop="type" :rules="[{ required: true, message: '请选择题目类型', trigger: 'change' }]">
          <el-select v-model="createForm.type" placeholder="请选择题目类型" style="width: 100%">
            <el-option label="单选题" value="单选题" />
            <el-option label="多选题" value="多选题" />
            <el-option label="判断题" value="判断题" />
            <el-option label="填空题" value="填空题" />
          </el-select>
        </el-form-item>

        <el-form-item label="难度等级" prop="difficulty">
          <el-select v-model="createForm.difficulty" placeholder="请选择难度等级" style="width: 100%">
            <el-option label="简单" value="简单" />
            <el-option label="中等" value="中等" />
            <el-option label="困难" value="困难" />
          </el-select>
        </el-form-item>

        <el-form-item label="章节" prop="chapter">
          <el-input v-model="createForm.chapter" placeholder="请输入章节名称" />
        </el-form-item>

        <!-- 选项配置 -->
        <el-form-item label="选项配置" v-if="createForm.type === '单选题' || createForm.type === '多选题'">
          <div class="options-container">
            <div v-for="(option, index) in createForm.options" :key="index" class="option-item">
              <el-input
                v-model="option.key"
                placeholder="选项标识"
                style="width: 80px; margin-right: 10px;"
                disabled
              />
              <el-input
                v-model="option.content"
                placeholder="选项内容"
                style="flex: 1; margin-right: 10px;"
              />
              <el-button type="danger" size="small" @click="removeCreateOption(index)" v-if="createForm.options.length > 2">
                删除
              </el-button>
            </div>
            <el-button type="primary" size="small" @click="addCreateOption" v-if="createForm.options.length < 6">
              添加选项
            </el-button>
          </div>
        </el-form-item>

        <!-- 判断题选项 -->
        <el-form-item label="选项" v-if="createForm.type === '判断题'">
          <el-radio-group v-model="createForm.answer">
            <el-radio label="正确">正确</el-radio>
            <el-radio label="错误">错误</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="正确答案" prop="answer" :rules="[{ required: true, message: '请输入正确答案', trigger: 'blur' }]">
          <el-input
            v-model="createForm.answer"
            placeholder="请输入正确答案，如：A、AB、正确等"
            v-if="createForm.type !== '判断题'"
          />
        </el-form-item>

        <el-form-item label="解析" prop="analysis">
          <el-input
            v-model="createForm.analysis"
            type="textarea"
            :rows="3"
            placeholder="请输入题目解析"
          />
        </el-form-item>

        <!-- 解析图片 -->
        <el-form-item label="解析图片">
          <el-upload
            :action="`${getServerUrl()}/api/upload/image`"
            :headers="{ 'Authorization': `Bearer ${getToken()}` }"
            :on-success="handleCreateImageSuccess"
            :on-error="handleCreateImageError"
            :before-upload="beforeImageUpload"
            :file-list="createForm.images"
            list-type="picture-card"
            :limit="5"
            :on-remove="handleCreateImageRemove"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancelCreateQuestion">取消</el-button>
          <el-button type="primary" :loading="creating" @click="saveCreateQuestion">
            创建
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Upload, ArrowLeft, Plus, Document, Calendar, QuestionFilled, Delete } from '@element-plus/icons-vue'
import { questionBankAPI } from '../api/questionBank.js'
import { subjectAPI } from '../api/subject.js'
import { adminAPI } from '../api/admin.js'

// 响应式数据
const loading = ref(false)
const questionBanks = ref([])
const subjects = ref([])
const questions = ref([])
const selectedQuestions = ref([])
const currentQuestionBank = ref(null)
const currentSubject = ref(null)
const showCreateDialog = ref(false)
const showCreateSubjectDialog = ref(false)
const showCreateQuestionDialog = ref(false)
const showDetailDialog = ref(false)
const currentQuestion = ref(null)
const editing = ref(false)
const saving = ref(false)
const creating = ref(false)
const editingBank = ref(null) // 正在编辑的题库
const editingSubject = ref(null) // 正在编辑的科目

// 编辑表单
const editForm = ref({
  id: '',
  subject: '',
  chapter: '',
  type: '',
  difficulty: '',
  content: '',
  options: [],
  answer: '',
  analysis: '',
  images: [],
  questionImages: []
})

// 创建表单
const createForm = ref({
  chapter: '',
  type: '单选题',
  difficulty: '中等',
  content: '',
  options: [
    { key: 'A', content: '' },
    { key: 'B', content: '' }
  ],
  answer: '',
  analysis: '',
  images: []
})

const createFormRef = ref(null)

// 图片上传相关
const getServerUrl = () => {
  // 生产环境走同域名，通过nginx代理到后端API
  if (import.meta.env.PROD) {
    return ''
  }
  // 开发环境使用环境变量或默认远端
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

const uploadUrl = ref(`${getServerUrl()}/api/upload/image`)
const uploadHeaders = ref({
  'Authorization': `Bearer ${localStorage.getItem('token')}`
})

// 搜索表单
const searchForm = reactive({
  keyword: ''
})

// 创建题库表单
const createBankForm = reactive({
  name: '',
  description: ''
})

const createSubjectForm = reactive({
  name: '',
  description: ''
})

// 分页
const pagination = reactive({
  page: 1,
  limit: 10,
  total: 0
})

// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

// 获取类型标签类型
const getTypeTagType = (type) => {
  const typeMap = {
    '单选题': 'primary',
    '多选题': 'success',
    '判断题': 'warning',
    '填空题': 'info'
  }
  return typeMap[type] || 'default'
}

// 获取难度标签类型
const getDifficultyTagType = (difficulty) => {
  const difficultyMap = {
    '简单': 'success',
    '中等': 'warning',
    '困难': 'danger'
  }
  return difficultyMap[difficulty] || 'default'
}

// 加载题库列表
const loadQuestionBanks = async () => {
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

    const response = await questionBankAPI.getQuestionBanks(params)
    
    if (response.code === 200) {
      questionBanks.value = response.data.list || []
      pagination.total = response.data.total || 0
    } else {
      ElMessage.error(response.message || '获取题库列表失败')
    }
  } catch (error) {
    console.error('加载题库列表失败:', error)
    ElMessage.error('加载题库列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 加载科目列表
const loadSubjects = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      limit: pagination.limit,
      questionBankId: currentQuestionBank.value.id
    }

    const response = await subjectAPI.getSubjects(params)
    
    if (response.code === 200) {
      subjects.value = response.data.list || []
      pagination.total = response.data.total || 0
    } else {
      ElMessage.error(response.message || '获取科目列表失败')
    }
  } catch (error) {
    console.error('加载科目列表失败:', error)
    ElMessage.error('加载科目列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 加载题目列表
const loadQuestions = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      limit: pagination.limit,
      subjectId: currentSubject.value.id
    }

    const response = await adminAPI.getQuestions(params)
    
    if (response.code === 200) {
      questions.value = response.data.list || []
      pagination.total = response.data.total || 0
    } else {
      ElMessage.error(response.message || '获取题目列表失败')
    }
  } catch (error) {
    console.error('加载题目列表失败:', error)
    ElMessage.error('加载题目列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  if (currentSubject.value) {
    loadQuestions()
  } else if (currentQuestionBank.value) {
    loadSubjects()
  } else {
    loadQuestionBanks()
  }
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  pagination.page = 1
  if (currentSubject.value) {
    loadQuestions()
  } else if (currentQuestionBank.value) {
    loadSubjects()
  } else {
    loadQuestionBanks()
  }
}

// 分页处理
const handleSizeChange = (size) => {
  pagination.limit = size
  pagination.page = 1
  if (currentSubject.value) {
    loadQuestions()
  } else if (currentQuestionBank.value) {
    loadSubjects()
  } else {
    loadQuestionBanks()
  }
}

const handleCurrentChange = (page) => {
  pagination.page = page
  if (currentSubject.value) {
    loadQuestions()
  } else if (currentQuestionBank.value) {
    loadSubjects()
  } else {
    loadQuestionBanks()
  }
}

// 选择处理
const handleSelectionChange = (selection) => {
  selectedQuestions.value = selection
  console.log('选中的题目:', selectedQuestions.value)
}

// 批量删除题目
const batchDeleteQuestions = async () => {
  if (selectedQuestions.value.length === 0) {
    ElMessage.warning('请选择要删除的题目')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedQuestions.value.length} 道题目吗？此操作不可恢复！`,
      '批量删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        dangerouslyUseHTMLString: true
      }
    )

    const questionIds = selectedQuestions.value.map(q => q.id)
    console.log('要删除的题目ID:', questionIds)

    // 调用批量删除API
    const response = await adminAPI.batchDeleteQuestions(questionIds)
    
    if (response.code === 200) {
      ElMessage.success(`成功删除 ${response.data.deletedCount} 道题目`)
      // 清空选择
      selectedQuestions.value = []
      // 重新加载题目列表
      loadQuestions()
    } else {
      ElMessage.error(response.message || '批量删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除失败:', error)
      ElMessage.error('批量删除失败: ' + error.message)
    }
  }
}

// 进入题库
const enterQuestionBank = (bank) => {
  currentQuestionBank.value = bank
  pagination.page = 1
  loadSubjects()
}

// 返回题库列表
const backToQuestionBanks = () => {
  currentQuestionBank.value = null
  currentSubject.value = null
  pagination.page = 1
  loadQuestionBanks()
}

// 进入科目
const enterSubject = (subject) => {
  currentSubject.value = subject
  pagination.page = 1
  loadQuestions()
}

// 返回科目列表
const backToSubjects = () => {
  currentSubject.value = null
  pagination.page = 1
  loadSubjects()
}

// 编辑题库
const editQuestionBank = (bank) => {
  editingBank.value = bank
  createBankForm.name = bank.name
  createBankForm.description = bank.description || ''
  showCreateDialog.value = true
}

// 取消题库编辑
const cancelBankEdit = () => {
  showCreateDialog.value = false
  editingBank.value = null
  createBankForm.name = ''
  createBankForm.description = ''
}

// 保存题库（创建或编辑）
const saveQuestionBank = async () => {
  if (!createBankForm.name.trim()) {
    ElMessage.error('请输入题库名称')
    return
  }

  try {
    let response
    if (editingBank.value) {
      // 编辑模式
      response = await questionBankAPI.updateQuestionBank(editingBank.value.id, createBankForm)
      if (response.code === 200) {
        ElMessage.success('题库更新成功')
        showCreateDialog.value = false
        editingBank.value = null
        createBankForm.name = ''
        createBankForm.description = ''
        loadQuestionBanks()
      } else {
        ElMessage.error(response.message || '更新题库失败')
      }
    } else {
      // 创建模式
      response = await questionBankAPI.createQuestionBank(createBankForm)
      if (response.code === 200) {
        ElMessage.success('创建题库成功')
        showCreateDialog.value = false
        createBankForm.name = ''
        createBankForm.description = ''
        loadQuestionBanks()
      } else {
        ElMessage.error(response.message || '创建题库失败')
      }
    }
  } catch (error) {
    console.error('保存题库失败:', error)
    ElMessage.error('保存题库失败: ' + error.message)
  }
}

// 编辑科目
const editSubject = (subject) => {
  editingSubject.value = subject
  createSubjectForm.name = subject.name
  createSubjectForm.description = subject.description || ''
  showCreateSubjectDialog.value = true
}

// 取消科目编辑
const cancelSubjectEdit = () => {
  showCreateSubjectDialog.value = false
  editingSubject.value = null
  createSubjectForm.name = ''
  createSubjectForm.description = ''
}

// 保存科目（创建或编辑）
const saveSubject = async () => {
  if (!createSubjectForm.name.trim()) {
    ElMessage.error('请输入科目名称')
    return
  }

  try {
    let response
    if (editingSubject.value) {
      // 编辑模式
      response = await subjectAPI.updateSubject(editingSubject.value.id, createSubjectForm)
      if (response.code === 200) {
        ElMessage.success('科目更新成功')
        showCreateSubjectDialog.value = false
        editingSubject.value = null
        createSubjectForm.name = ''
        createSubjectForm.description = ''
        loadSubjects()
      } else {
        ElMessage.error(response.message || '更新科目失败')
      }
    } else {
      // 创建模式
      const data = {
        ...createSubjectForm,
        questionBankId: currentQuestionBank.value.id
      }
      response = await subjectAPI.createSubject(data)
      if (response.code === 200) {
        ElMessage.success('创建科目成功')
        showCreateSubjectDialog.value = false
        createSubjectForm.name = ''
        createSubjectForm.description = ''
        loadSubjects()
      } else {
        ElMessage.error(response.message || '创建科目失败')
      }
    }
  } catch (error) {
    console.error('保存科目失败:', error)
    ElMessage.error('保存科目失败: ' + error.message)
  }
}

// 删除题库
const deleteQuestionBank = async (bank) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题库"${bank.name}"吗？这将删除该题库下的所有科目和题目。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await questionBankAPI.deleteQuestionBank(bank.id)
    
    if (response.code === 200) {
      ElMessage.success('删除题库成功')
      loadQuestionBanks()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除题库失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

// 删除科目
const deleteSubject = async (subject) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除科目"${subject.name}"吗？这将删除该科目下的所有题目。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await subjectAPI.deleteSubject(subject.id)
    
    if (response.code === 200) {
      ElMessage.success('删除科目成功')
      loadSubjects()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除科目失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

// 编辑题目
const editQuestion = (question) => {
  currentQuestion.value = question
  showDetailDialog.value = true
  // 直接进入编辑模式
  startEdit()
}

// 开始编辑
const startEdit = () => {
  if (!currentQuestion.value) {
    console.error('currentQuestion is null')
    return
  }
  
  console.log('=== 开始编辑题目 ===')
  console.log('currentQuestion.value 完整数据:', currentQuestion.value)
  console.log('currentQuestion.value.images:', currentQuestion.value.images)
  console.log('currentQuestion.value.questionImages:', currentQuestion.value.questionImages)
  
  // 初始化编辑表单
  editForm.value = {
    id: currentQuestion.value.id,
    subject: currentQuestion.value.subject,
    chapter: currentQuestion.value.chapter || '',
    type: currentQuestion.value.type,
    difficulty: currentQuestion.value.difficulty || '简单',
    content: currentQuestion.value.content,
    options: parseOptions(currentQuestion.value.options),
    answer: currentQuestion.value.answer,
    analysis: currentQuestion.value.analysis || '',
    images: parseImages(currentQuestion.value.images),
    questionImages: parseImages(currentQuestion.value.questionImages)
  }
  
  console.log('=== 编辑表单初始化完成 ===')
  console.log('editForm.value.images:', editForm.value.images)
  console.log('editForm.value.questionImages:', editForm.value.questionImages)
  editing.value = true
}

// 解析选项数据
const parseOptions = (options) => {
  if (!options) return []
  
  try {
    // 如果是字符串，尝试解析JSON
    if (typeof options === 'string') {
      const parsed = JSON.parse(options)
      if (Array.isArray(parsed)) {
        return parsed.map(option => ({
          content: typeof option === 'string' ? option : option.content || ''
        }))
      }
    }
    
    // 如果是数组
    if (Array.isArray(options)) {
      return options.map(option => ({
        content: typeof option === 'string' ? option : option.content || ''
      }))
    }
    
    return []
  } catch (error) {
    console.error('解析选项失败:', error)
    return []
  }
}

// 解析图片数据
const parseImages = (images) => {
  console.log('=== parseImages 函数调用 ===')
  console.log('接收到的 images 参数:', images)
  console.log('images 类型:', typeof images)
  
  if (!images) {
    console.log('images 为空，返回空数组')
    return []
  }
  
  try {
    let parsedImages = []
    
    // 如果是字符串，尝试解析JSON
    if (typeof images === 'string') {
      console.log('images 是字符串，尝试解析 JSON')
      const parsed = JSON.parse(images)
      console.log('JSON 解析后的数据:', parsed)
      if (Array.isArray(parsed)) {
        parsedImages = parsed
        console.log('解析后是数组，长度:', parsedImages.length)
      } else {
        console.log('解析后不是数组')
      }
    }
    // 如果是数组
    else if (Array.isArray(images)) {
      console.log('images 是数组，长度:', images.length)
      parsedImages = images
    } else {
      console.log('images 既不是字符串也不是数组')
    }
    
    // 处理图片数据，确保每个图片对象都有有效的path属性
    const result = parsedImages
      .filter(image => {
        const isValid = image && typeof image === 'object' && image.path && typeof image.path === 'string'
        console.log('图片过滤检查:', { image, isValid })
        return isValid
      })
      .map((image, index) => {
        console.log('处理单个图片对象:', image)
        const resultImage = {
          uid: image.uid || Date.now() + index, // 添加 uid 用于 el-upload 组件识别
          name: image.name || 'image',
          url: getImageUrl(image.path),
          path: image.path
        }
        console.log('处理后的图片对象:', resultImage)
        return resultImage
      })
    
    console.log('=== parseImages 返回结果 ===')
    console.log('最终返回的图片数组:', result)
    return result
  } catch (error) {
    console.error('解析图片失败:', error)
    return []
  }
}

// 获取图片URL
const getImageUrl = (path) => {
  console.log('获取图片URL - 输入路径:', path, '类型:', typeof path)
  
  // 验证输入参数
  if (!path || typeof path !== 'string') {
    console.warn('无效的图片路径:', path)
    return ''
  }
  
  if (path.startsWith('http')) return path
  
  // 处理路径，确保包含 images/ 前缀
  let cleanPath = path.trim()
  if (cleanPath.startsWith('/')) {
    cleanPath = cleanPath.substring(1) // 移除开头的斜杠
  }
  
  // 如果路径不包含 images/ 前缀，添加它
  if (!cleanPath.startsWith('images/')) {
    cleanPath = `images/${cleanPath}`
  }
  
  const url = `${getServerUrl()}/uploads/${cleanPath}`
  console.log('获取图片URL - 生成URL:', url)
  return url
}

// 获取有效的图片数据
const getValidImages = () => {
  if (!currentQuestion.value?.images) return []
  
  try {
    const images = typeof currentQuestion.value.images === 'string' 
      ? JSON.parse(currentQuestion.value.images) 
      : currentQuestion.value.images
    
    if (!Array.isArray(images)) {
      console.warn('图片数据不是数组格式:', images)
      return []
    }
    
    return images.filter(image => 
      image && 
      typeof image === 'object' && 
      image.path && 
      typeof image.path === 'string' &&
      image.path.trim() !== ''
    )
  } catch (error) {
    console.error('获取有效图片数据失败:', error)
    return []
  }
}

// 获取图片预览列表
const getImagePreviewList = () => {
  const validImages = getValidImages()
  return validImages.map(image => getImageUrl(image.path))
}

// 添加选项
const addOption = () => {
  if (editForm.value.options.length < 6) {
    editForm.value.options.push({ content: '' })
  }
}

// 删除选项
const removeOption = (index) => {
  if (editForm.value.options.length > 2) {
    editForm.value.options.splice(index, 1)
  }
}

// 保存题目
const saveQuestion = async () => {
  if (!editForm.value.content.trim()) {
    ElMessage.error('请输入题目内容')
    return
  }
  
  if (editForm.value.options.length < 2) {
    ElMessage.error('至少需要2个选项')
    return
  }
  
  if (!editForm.value.answer.trim()) {
    ElMessage.error('请输入正确答案')
    return
  }
  
  saving.value = true
  try {
    // 处理图片数据，确保数据有效性
    let imagesData = []
    if (editForm.value.images && Array.isArray(editForm.value.images)) {
      imagesData = editForm.value.images
        .filter(img => img && img.path && typeof img.path === 'string' && img.path.trim() !== '')
        .map(img => ({ path: img.path }))
    }
    
    // 处理题目图片数据
    let questionImagesData = []
    if (editForm.value.questionImages && Array.isArray(editForm.value.questionImages)) {
      questionImagesData = editForm.value.questionImages
        .filter(img => img && img.path && typeof img.path === 'string' && img.path.trim() !== '')
        .map(img => ({ path: img.path }))
    }
    
    console.log('保存时的图片数据:', imagesData)
    console.log('保存时的题目图片数据:', questionImagesData)
    
    const updateData = {
      chapter: editForm.value.chapter,
      type: editForm.value.type,
      difficulty: editForm.value.difficulty,
      content: editForm.value.content,
      options: JSON.stringify(editForm.value.options.map(opt => opt.content)),
      answer: editForm.value.answer,
      analysis: editForm.value.analysis,
      images: JSON.stringify(imagesData),
      questionImages: JSON.stringify(questionImagesData)
    }
    
    const response = await adminAPI.updateQuestion(editForm.value.id, updateData)
    
    if (response.code === 200) {
      ElMessage.success('保存成功')
      editing.value = false
      showDetailDialog.value = false
      loadQuestions()
    } else {
      ElMessage.error(response.message || '保存失败')
    }
  } catch (error) {
    console.error('保存题目失败:', error)
    ElMessage.error('保存失败: ' + error.message)
  } finally {
    saving.value = false
  }
}

// 图片上传成功处理
const handleImageSuccess = (response, file, fileList) => {
  console.log('图片上传成功 - 响应数据:', response)
  console.log('图片上传成功 - 文件信息:', file)
  
  if (response.code === 200) {
    // 更新文件对象的 path 属性
    file.path = response.data.path
    file.url = response.data.url
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error(response.message || '图片上传失败')
  }
}

// 图片文件列表变化处理
const handleImageChange = (file, fileList) => {
  console.log('图片文件列表变化:', { file, fileList })
  // 同步更新 editForm.images
  editForm.value.images = fileList.map(f => ({
    uid: f.uid,
    name: f.name,
    url: f.url,
    path: f.path
  }))
  console.log('更新后的 editForm.images:', editForm.value.images)
}

// 图片上传失败处理
const handleImageError = (error, file, fileList) => {
  console.error('图片上传失败:', error)
  ElMessage.error('图片上传失败')
}

// 图片上传前验证
const beforeImageUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

// 题目图片上传成功处理
const handleQuestionImageSuccess = (response, file, fileList) => {
  console.log('题目图片上传成功 - 响应数据:', response)
  console.log('题目图片上传成功 - 文件信息:', file)
  
  if (response.code === 200) {
    // 更新文件对象的 path 属性
    file.path = response.data.path
    file.url = response.data.url
    ElMessage.success('题目图片上传成功')
  } else {
    ElMessage.error(response.message || '题目图片上传失败')
  }
}

// 题目图片文件列表变化处理
const handleQuestionImageChange = (file, fileList) => {
  console.log('题目图片文件列表变化:', { file, fileList })
  // 同步更新 editForm.questionImages
  editForm.value.questionImages = fileList.map(f => ({
    uid: f.uid,
    name: f.name,
    url: f.url,
    path: f.path
  }))
  console.log('更新后的 editForm.questionImages:', editForm.value.questionImages)
}

// 题目图片上传失败处理
const handleQuestionImageError = (error, file, fileList) => {
  console.error('题目图片上传失败:', error)
  ElMessage.error('题目图片上传失败')
}

// 题目图片上传前验证
const beforeQuestionImageUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

// 获取题目图片预览列表
const getQuestionImagePreviewList = () => {
  if (!currentQuestion.value?.questionImages) return []
  
  try {
    const images = typeof currentQuestion.value.questionImages === 'string' 
      ? JSON.parse(currentQuestion.value.questionImages) 
      : currentQuestion.value.questionImages
    
    return images
      .filter(image => image && typeof image === 'object' && image.path && typeof image.path === 'string')
      .map(image => ({ path: image.path }))
  } catch (error) {
    return []
  }
}

// 删除题目
const deleteQuestion = async (question) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题目"${question.content.substring(0, 50)}..."吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await adminAPI.deleteQuestion(question.id)
    
    if (response.code === 200) {
      ElMessage.success('删除成功')
      loadQuestions()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除题目失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

// 辅助方法
const getTypeText = (type) => {
  const typeMap = {
    '单选题': '单选题',
    '多选题': '多选题',
    '判断题': '判断题',
    '填空题': '填空题'
  }
  return typeMap[type] || type
}

// 创建题目相关方法
const createQuestion = () => {
  // 重置创建表单
  createForm.value = {
    chapter: '',
    type: '单选题',
    difficulty: '中等',
    content: '',
    options: [
      { key: 'A', content: '' },
      { key: 'B', content: '' }
    ],
    answer: '',
    analysis: '',
    images: []
  }
  showCreateQuestionDialog.value = true
}

const cancelCreateQuestion = () => {
  showCreateQuestionDialog.value = false
  createForm.value = {
    chapter: '',
    type: '单选题',
    difficulty: '中等',
    content: '',
    options: [
      { key: 'A', content: '' },
      { key: 'B', content: '' }
    ],
    answer: '',
    analysis: '',
    images: []
  }
}

const addCreateOption = () => {
  if (createForm.value.options.length < 6) {
    const nextKey = String.fromCharCode(65 + createForm.value.options.length) // A, B, C, D, E, F
    createForm.value.options.push({ key: nextKey, content: '' })
  }
}

const removeCreateOption = (index) => {
  if (createForm.value.options.length > 2) {
    createForm.value.options.splice(index, 1)
    // 重新分配选项标识
    createForm.value.options.forEach((option, idx) => {
      option.key = String.fromCharCode(65 + idx)
    })
  }
}

const saveCreateQuestion = async () => {
  if (!createFormRef.value) return
  
  try {
    await createFormRef.value.validate()
  } catch (error) {
    ElMessage.error('请完善必填信息')
    return
  }

  if (!createForm.value.content.trim()) {
    ElMessage.error('请输入题目内容')
    return
  }

  if ((createForm.value.type === '单选题' || createForm.value.type === '多选题') && createForm.value.options.length < 2) {
    ElMessage.error('至少需要2个选项')
    return
  }

  if (!createForm.value.answer.trim()) {
    ElMessage.error('请输入正确答案')
    return
  }

  creating.value = true

  try {
    // 调试信息
    console.log('创建表单选项数据:', createForm.value.options)
    console.log('创建表单图片数据:', createForm.value.images)
    
    // 准备题目数据
    const questionData = {
      questionBankId: currentQuestionBank.value.id,
      subjectId: currentSubject.value.id,
      chapter: createForm.value.chapter,
      type: createForm.value.type,
      difficulty: createForm.value.difficulty,
      content: createForm.value.content,
      answer: createForm.value.answer,
      analysis: createForm.value.analysis,
      options: createForm.value.type === '单选题' || createForm.value.type === '多选题' 
        ? JSON.stringify(createForm.value.options) 
        : null,
      images: createForm.value.images.length > 0 
        ? JSON.stringify(createForm.value.images) 
        : null
    }

    console.log('创建题目数据:', questionData)
    console.log('选项JSON字符串:', questionData.options)
    console.log('图片JSON字符串:', questionData.images)

    const response = await adminAPI.addQuestion(questionData)
    
    if (response.code === 200) {
      ElMessage.success('题目创建成功')
      showCreateQuestionDialog.value = false
      // 重新加载题目列表
      loadQuestions()
    } else {
      ElMessage.error(response.message || '创建失败')
    }
  } catch (error) {
    console.error('创建题目失败:', error)
    ElMessage.error('创建题目失败: ' + error.message)
  } finally {
    creating.value = false
  }
}

// 创建题目图片上传相关方法
const handleCreateImageSuccess = (response, file, fileList) => {
  console.log('创建题目图片上传成功:', response)
  if (response.code === 200) {
    createForm.value.images.push({
      name: response.data.fileName,
      path: response.data.path,
      url: getImageUrl(response.data.path)
    })
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error(response.message || '图片上传失败')
  }
}

const handleCreateImageError = (error, file, fileList) => {
  console.error('创建题目图片上传失败:', error)
  ElMessage.error('图片上传失败')
}

const handleCreateImageRemove = (file, fileList) => {
  console.log('移除创建题目图片:', file)
  const index = createForm.value.images.findIndex(img => img.name === file.name)
  if (index > -1) {
    createForm.value.images.splice(index, 1)
  }
}

// 获取token的辅助方法
const getToken = () => {
  return localStorage.getItem('token')
}

// 组件挂载时加载数据
onMounted(() => {
  loadQuestionBanks()
})
</script>

<style scoped>
.question-bank-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.search-section {
  margin-bottom: 20px;
}

.bank-grid, .subject-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.bank-card, .subject-card {
  cursor: pointer;
  transition: all 0.3s;
}

.bank-card:hover, .subject-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.bank-info, .subject-info {
  margin-bottom: 15px;
}

.bank-name, .subject-name {
  margin: 0 0 10px 0;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.bank-description, .subject-description {
  margin: 0 0 15px 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.4;
}

.bank-stats, .subject-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: #909399;
}

.bank-actions, .subject-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.bank-title, .subject-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

/* 编辑表单样式 */
.edit-form {
  max-height: 600px;
  overflow-y: auto;
}

.options-editor {
  width: 100%;
}

.option-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.option-item .el-input {
  flex: 1;
}

.image-upload-section {
  width: 100%;
}

.upload-tip {
  margin-top: 10px;
  font-size: 12px;
  color: #909399;
}

.images-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.analysis-image {
  width: 100%;
  height: 120px;
  border-radius: 4px;
  cursor: pointer;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.question-detail {
  max-height: 600px;
  overflow-y: auto;
}

.question-content {
  margin-top: 20px;
}

.question-content h4 {
  margin: 15px 0 10px 0;
  color: #409eff;
}

.question-content p {
  margin: 5px 0;
  line-height: 1.6;
}

.question-content ul {
  margin: 10px 0;
  padding-left: 20px;
}

.question-content li {
  margin: 5px 0;
  line-height: 1.6;
}

.answer-section {
  background-color: #f0f9ff;
  padding: 15px;
  border-radius: 4px;
  border-left: 4px solid #409eff;
}

.answer {
  font-weight: bold;
  color: #67c23a;
}

/* 创建题目对话框样式 */
.options-container {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 10px;
  background-color: #fafafa;
}

.option-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.option-item:last-child {
  margin-bottom: 0;
}

.dialog-footer {
  text-align: right;
}

.dialog-footer .el-button {
  margin-left: 10px;
}
</style>
