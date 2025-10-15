<template>
  <div class="question-import">
    <el-card class="import-card">
      <template #header>
        <div class="card-header">
          <span class="card-title">题库导入</span>
          <el-button @click="$router.go(-1)" type="text">
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
        </div>
      </template>

      <!-- 导入步骤 -->
      <el-steps :active="currentStep" finish-status="success" class="import-steps">
        <el-step title="选择文件" description="上传Excel或CSV文件" />
        <el-step title="预览数据" description="检查数据格式和内容" />
        <el-step title="确认导入" description="确认并执行导入" />
      </el-steps>

      <!-- 步骤1：文件上传 -->
      <div v-if="currentStep === 0" class="step-content">
        <div class="upload-area">
          <el-upload
            ref="uploadRef"
            :auto-upload="false"
            :on-change="handleFileChange"
            :before-upload="beforeUpload"
            :file-list="fileList"
            accept=".xlsx,.xls,.csv,.docx,.doc,.txt"
            drag
            class="upload-dragger"
          >
            <el-icon class="upload-icon"><Upload /></el-icon>
            <div class="upload-text">
              <span>将文件拖到此处，或<em>点击上传</em></span>
              <p class="upload-tip">支持 .xlsx、.xls、.csv、.docx、.doc、.txt 格式文件</p>
            </div>
          </el-upload>
        </div>

        <!-- 文件模板下载 -->
        <div class="template-download">
          <h4>下载模板文件：</h4>
          <div class="template-buttons">
            <el-button type="primary" @click="downloadTemplate('excel')">
              <el-icon><Download /></el-icon>
              下载Excel模板
            </el-button>
            <el-button type="success" @click="downloadTemplate('csv')">
              <el-icon><Download /></el-icon>
              下载CSV模板
            </el-button>
          </div>
        </div>

                 <!-- 导入说明 -->
         <div class="import-guide">
           <h4>导入说明：</h4>
           <el-alert
             title="支持多种文件格式，请根据文件类型选择相应的格式要求"
             type="info"
             :closable="false"
             show-icon
           />
           <div class="guide-list">
             <h5>Excel/CSV 格式要求：</h5>
             <p>请确保文件包含以下列：题目类型、题目内容、选项A、选项B、选项C、选项D、正确答案、解析、难度等级</p>
             
                           <h5>Word/TXT 格式要求：</h5>
              <p>题目格式示例：</p>
              <pre>1. 单选题内容
A. 选项A内容
B. 选项B内容
C. 选项C内容
D. 选项D内容
答案：B
解析：解析内容
难度：中等

2. 多选题内容
A. 选项A内容
B. 选项B内容
C. 选项C内容
D. 选项D内容
答案：AB
解析：解析内容
难度：中等</pre>
             
             <h5>通用字段说明：</h5>
             <p><strong>题目类型：</strong>单选题、多选题、判断题</p>
             <p><strong>题目内容：</strong>题目描述文字</p>
             <p><strong>选项A-D：</strong>选择题的选项内容（判断题可留空）</p>
                           <p><strong>正确答案：</strong>单选题填写选项字母（A/B/C/D），多选题填写多个字母（如：AB、A,B、A B等），判断题填写（正确/错误）</p>
             <p><strong>解析：</strong>题目解析说明</p>
             <p><strong>难度等级：</strong>简单、中等、困难</p>
           </div>
         </div>
      </div>

      <!-- 步骤2：数据预览 -->
      <div v-if="currentStep === 1" class="step-content">
        <div class="preview-header">
          <h3>数据预览</h3>
          <div class="preview-stats">
            <el-tag type="success">总题数：{{ previewData.length }}</el-tag>
            <el-tag type="warning">错误数据：{{ errorCount }}</el-tag>
            <el-tag type="info">有效数据：{{ validCount }}</el-tag>
          </div>
        </div>

        <!-- 数据表格 -->
        <el-table
          :data="previewData"
          style="width: 100%"
          max-height="400"
          border
          stripe
        >
          <el-table-column prop="type" label="题目类型" width="100" />
          <el-table-column prop="content" label="题目内容" min-width="200" show-overflow-tooltip />
          <el-table-column prop="optionA" label="选项A" width="120" show-overflow-tooltip />
          <el-table-column prop="optionB" label="选项B" width="120" show-overflow-tooltip />
          <el-table-column prop="optionC" label="选项C" width="120" show-overflow-tooltip />
          <el-table-column prop="optionD" label="选项D" width="120" show-overflow-tooltip />
          <el-table-column prop="answer" label="正确答案" width="100" />
          <el-table-column prop="analysis" label="解析" width="200" show-overflow-tooltip>
            <template #default="scope">
              <div>
                <div>{{ scope.row.analysis }}</div>
                <!-- 显示解析中的图片 -->
                <div v-if="scope.row.images && scope.row.images.length > 0" style="margin-top: 8px;">
                  <div v-for="(image, index) in scope.row.images" :key="index" style="margin: 4px 0;">
                    <el-image
                      :src="getImageUrl(image.path)"
                      :preview-src-list="getImagePreviewList(scope.row.images)"
                      style="width: 60px; height: 40px; border-radius: 4px;"
                      fit="cover"
                      :initial-index="index"
                    />
                  </div>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="difficulty" label="难度" width="80" />
          <el-table-column label="状态" width="80">
            <template #default="{ row }">
              <el-tag :type="row.isValid ? 'success' : 'danger'" size="small">
                {{ row.isValid ? '有效' : '错误' }}
              </el-tag>
            </template>
          </el-table-column>
        </el-table>

        <!-- 错误信息 -->
        <div v-if="errorMessages.length > 0" class="error-messages">
          <h4>错误信息：</h4>
          <el-alert
            v-for="(error, index) in errorMessages"
            :key="index"
            :title="error"
            type="error"
            :closable="false"
            show-icon
          />
        </div>
      </div>

      <!-- 步骤3：确认导入 -->
      <div v-if="currentStep === 2" class="step-content">
        <div class="confirm-header">
          <h3>确认导入</h3>
          <p>即将导入 {{ validCount }} 道题目到题库中</p>
        </div>

        <!-- 导入选项 -->
        <div class="import-options">
          <h4>题库和科目信息：</h4>
          <el-form :model="importOptions" label-width="120px">
            <el-form-item label="选择题库：" required>
              <el-select 
                v-model="importOptions.questionBankId" 
                placeholder="请选择题库"
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
            </el-form-item>
            <el-form-item label="选择科目：" required>
              <el-select 
                v-model="importOptions.subjectId" 
                placeholder="请选择科目"
                style="width: 100%"
                :disabled="!importOptions.questionBankId"
              >
                <el-option
                  v-for="subject in subjects"
                  :key="subject.id"
                  :label="subject.name"
                  :value="subject.id"
                />
              </el-select>
            </el-form-item>
            <el-form-item label="重复处理：">
              <el-radio-group v-model="importOptions.duplicateHandling">
                <el-radio label="skip">跳过重复题目</el-radio>
                <el-radio label="update">更新重复题目</el-radio>
                <el-radio label="force">强制导入</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-form>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="step-actions">
        <el-button v-if="currentStep > 0" @click="prevStep">上一步</el-button>
        <el-button 
          v-if="currentStep < 2" 
          type="primary" 
          @click="nextStep"
          :disabled="!canProceed"
        >
          下一步
        </el-button>
        <el-button 
          v-if="currentStep === 2" 
          type="success" 
          @click="confirmImport"
          :loading="importing"
        >
          确认导入
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, Upload, Download } from '@element-plus/icons-vue'
import * as XLSX from 'xlsx'
import mammoth from 'mammoth'
import { questionBankAPI } from '../api/questionBank.js'
import { subjectAPI } from '../api/subject.js'
import { questionAPI } from '@/api/question'

const router = useRouter()

// 获取服务器URL
const getServerUrl = () => {
  // 在生产环境中使用环境变量配置的服务器地址
  if (import.meta.env.PROD) {
    return import.meta.env.VITE_SERVER_URL || 'https://admin.practice.insightdata.top:8443';
  }
  // 开发环境使用完整URL
  return import.meta.env.VITE_SERVER_URL || 'https://practice.insightdata.top'
}

// 当前步骤
const currentStep = ref(0)

// 文件相关
const uploadRef = ref(null)
const fileList = ref([])

// 预览数据
const previewData = ref([])
const errorMessages = ref([])

// 导入选项
const importOptions = reactive({
  questionBankId: '',
  subjectId: '',
  duplicateHandling: 'skip'
})

// 题库和科目数据
const questionBanks = ref([])
const subjects = ref([])

// 导入状态
const importing = ref(false)

// 计算属性
const errorCount = computed(() => {
  return previewData.value.filter(item => !item.isValid).length
})

const validCount = computed(() => {
  return previewData.value.filter(item => item.isValid).length
})

const canProceed = computed(() => {
  if (currentStep.value === 0) {
    return fileList.value.length > 0
  }
  if (currentStep.value === 1) {
    return validCount.value > 0
  }
  return true
})

// 文件上传处理
const handleFileChange = (file) => {
  fileList.value = [file]
}

const beforeUpload = (file) => {
  const isValidType = /\.(xlsx|xls|csv|docx|doc|txt)$/.test(file.name)
  if (!isValidType) {
    ElMessage.error('只能上传 Excel、CSV、Word 或 TXT 文件！')
    return false
  }
  return false // 阻止自动上传
}

// 下载模板
const downloadTemplate = (type) => {
  const templateData = [
    {
      '题目类型': '单选题',
      '题目内容': '1+1等于多少？',
      '选项A': '1',
      '选项B': '2',
      '选项C': '3',
      '选项D': '4',
      '正确答案': 'B',
      '解析': '1+1=2，这是基本的数学运算',
      '难度等级': '简单'
    },
    {
      '题目类型': '多选题',
      '题目内容': '以下哪些是水果？',
      '选项A': '苹果',
      '选项B': '胡萝卜',
      '选项C': '香蕉',
      '选项D': '土豆',
      '正确答案': 'AC',
      '解析': '苹果和香蕉是水果，胡萝卜和土豆是蔬菜',
      '难度等级': '中等'
    }
  ]

  if (type === 'excel') {
    const ws = XLSX.utils.json_to_sheet(templateData)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, '题库模板')
    XLSX.writeFile(wb, '题库导入模板.xlsx')
  } else {
    // CSV格式
    const csvContent = '题目类型,题目内容,选项A,选项B,选项C,选项D,正确答案,解析,难度等级\n' +
      templateData.map(row => 
        Object.values(row).map(value => `"${value}"`).join(',')
      ).join('\n')
    
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = '题库导入模板.csv'
    link.click()
  }
  
  ElMessage.success('模板文件下载成功')
}

// 数据验证
const validateData = (data) => {
  const errors = []
  const validatedData = []

  data.forEach((row, index) => {
    const rowNum = index + 2 // Excel行号从2开始
    const rowErrors = []

    // 验证必填字段
    if (!row['题目内容']) rowErrors.push('题目内容不能为空')
    if (!row['正确答案']) rowErrors.push('正确答案不能为空')

    // 验证题目类型（如果没有设置，默认为单选题）
    if (!row['题目类型']) {
      row['题目类型'] = '单选题'
    }
    const validTypes = ['单选题', '多选题', '判断题']
    if (row['题目类型'] && !validTypes.includes(row['题目类型'])) {
      rowErrors.push('题目类型必须是：单选题、多选题、判断题')
    }

    // 验证难度等级（如果没有设置，默认为中等）
    if (!row['难度等级']) {
      row['难度等级'] = '中等'
    }
    const validDifficulties = ['简单', '中等', '困难']
    if (row['难度等级'] && !validDifficulties.includes(row['难度等级'])) {
      rowErrors.push('难度等级必须是：简单、中等、困难')
    }

    // 验证选择题选项（更宽松的验证）
    if (row['题目类型'] === '单选题' || row['题目类型'] === '多选题') {
      // 检查是否有至少两个选项
      const options = [row['选项A'], row['选项B'], row['选项C'], row['选项D']].filter(opt => opt && opt.trim())
      if (options.length < 2) {
        rowErrors.push('选择题至少需要包含两个选项')
      }
    }

    // 验证答案格式
    if (row['题目类型'] === '单选题') {
      const validAnswers = ['A', 'B', 'C', 'D']
      if (row['正确答案'] && !validAnswers.includes(row['正确答案'])) {
        rowErrors.push('单选题答案必须是A、B、C、D之一')
      }
    } else if (row['题目类型'] === '多选题') {
      const answer = row['正确答案']
      if (answer) {
        // 支持多种格式：AB、A,B、A B、A;B等
        const cleanAnswer = answer.replace(/[,;\s]/g, '')
        if (!/^[A-D]+$/.test(cleanAnswer)) {
          rowErrors.push('多选题答案必须是A、B、C、D的组合，如：AB、A,B、A B等')
        } else {
          // 更新为标准化格式（去除分隔符）
          row['正确答案'] = cleanAnswer
        }
      }
    } else if (row['题目类型'] === '判断题') {
      const validAnswers = ['正确', '错误']
      if (row['正确答案'] && !validAnswers.includes(row['正确答案'])) {
        rowErrors.push('判断题答案必须是：正确、错误')
      }
    }

    const isValid = rowErrors.length === 0
    validatedData.push({
      type: row['题目类型'],
      content: row['题目内容'],
      optionA: row['选项A'] || '',
      optionB: row['选项B'] || '',
      optionC: row['选项C'] || '',
      optionD: row['选项D'] || '',
      answer: row['正确答案'],
      analysis: row['解析'] || '',
      difficulty: row['难度等级'] || '中等',
      images: row['图片'] || [], // 添加图片字段
      isValid,
      errors: rowErrors.length > 0 ? `第${rowNum}行：${rowErrors.join('，')}` : ''
    })

    if (rowErrors.length > 0) {
      errorMessages.value.push(`第${rowNum}行：${rowErrors.join('，')}`)
    }
  })

  return validatedData
}

// 读取文件
const readFile = (file) => {
  return new Promise((resolve, reject) => {
    const fileExtension = file.name.toLowerCase().split('.').pop()
    
    if (['xlsx', 'xls', 'csv'].includes(fileExtension)) {
      // 处理 Excel 和 CSV 文件
      const reader = new FileReader()
      reader.onload = (e) => {
        try {
          const data = e.target.result
          const workbook = XLSX.read(data, { type: 'binary' })
          const sheetName = workbook.SheetNames[0]
          const worksheet = workbook.Sheets[sheetName]
          const jsonData = XLSX.utils.sheet_to_json(worksheet)
          resolve(jsonData)
        } catch (error) {
          reject(new Error('Excel/CSV 文件读取失败：' + error.message))
        }
      }
      reader.onerror = () => reject(new Error('文件读取失败'))
      reader.readAsBinaryString(file)
    } else if (['docx', 'doc'].includes(fileExtension)) {
      // 处理 Word 文档
      const reader = new FileReader()
      reader.onload = async (e) => {
        try {
          const arrayBuffer = e.target.result
          const result = await mammoth.extractRawText({ arrayBuffer })
          const text = result.value
          
          // 提取图片（暂时返回空数组，因为前端无法直接处理图片）
          const images = []
          
          // 解析 Word 文档中的题目
          const questions = parseWordDocument(text, images)
          resolve(questions)
        } catch (error) {
          reject(new Error('Word 文档读取失败：' + error.message))
        }
      }
      reader.onerror = () => reject(new Error('文件读取失败'))
      reader.readAsArrayBuffer(file)
    } else if (fileExtension === 'txt') {
      // 处理 TXT 文件
      const reader = new FileReader()
      reader.onload = (e) => {
        try {
          const text = e.target.result
          const questions = parseTextDocument(text)
          resolve(questions)
        } catch (error) {
          reject(new Error('TXT 文件读取失败：' + error.message))
        }
      }
      reader.onerror = () => reject(new Error('文件读取失败'))
      reader.readAsText(file, 'utf-8')
    } else {
      reject(new Error('不支持的文件格式'))
    }
  })
}

// 解析 Word 文档
const parseWordDocument = (text, images = []) => {
  const questions = []
  const lines = text.split('\n').filter(line => line.trim())
  
  let currentQuestion = null
  let questionIndex = 0
  
  // 调试信息
  console.log('解析的文本内容：', text.substring(0, 1000))
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    
    // 检测题目开始（支持多种格式）
    const questionMatch = line.match(/^(\d+)[\.、\s]*(.+)/)
    if (questionMatch) {
      if (currentQuestion) {
        // 在添加题目前，根据答案判断题目类型
        if (currentQuestion['正确答案'] && currentQuestion['正确答案'].length > 1) {
          currentQuestion['题目类型'] = '多选题'
        }
        questions.push(currentQuestion)
      }
      
      questionIndex++
      currentQuestion = {
        '题目类型': '单选题', // 默认类型
        '题目内容': questionMatch[2].trim(),
        '选项A': '',
        '选项B': '',
        '选项C': '',
        '选项D': '',
        '正确答案': '',
        '解析': '',
        '难度等级': '中等',
        '图片': [] // 添加图片字段
      }
    } else if (currentQuestion) {
      // 检测选项（支持多种格式）
      const optionMatch = line.match(/^([A-D])[\.、\s]*(.+)/)
      if (optionMatch) {
        const option = optionMatch[1]
        const content = optionMatch[2].trim()
        currentQuestion[`选项${option}`] = content
      } else if (line.match(/^[A-D]\s*[\.、]/)) {
        // 处理只有选项字母的情况
        const option = line.charAt(0)
        const content = line.substring(1).replace(/^[\.、\s]+/, '').trim()
        if (content) {
          currentQuestion[`选项${option}`] = content
        }
      } else if (line.includes('答案') || line.includes('正确答案')) {
        // 检测答案（支持多种格式）
        console.log('检测到答案行：', line)
        
        // 尝试多种答案格式
        let foundAnswer = false
        
        // 格式1：答案：A 或 正确答案：A
        const answerMatch1 = line.match(/[答案正确答案：]\s*([A-D,\s;]+)/)
        if (answerMatch1) {
          const cleanAnswer = answerMatch1[1].replace(/[,;\s]/g, '')
          if (/^[A-D]+$/.test(cleanAnswer)) {
            currentQuestion['正确答案'] = cleanAnswer
            // 根据答案长度判断题目类型
            if (cleanAnswer.length > 1) {
              currentQuestion['题目类型'] = '多选题'
            }
            foundAnswer = true
            console.log('找到答案（格式1）：', cleanAnswer, '题目类型：', currentQuestion['题目类型'])
          }
        }
        
        // 格式2：答案 A 或 正确答案 A
        if (!foundAnswer) {
          const answerMatch2 = line.match(/[答案正确答案]\s+([A-D,\s;]+)/)
          if (answerMatch2) {
            const cleanAnswer = answerMatch2[1].replace(/[,;\s]/g, '')
            if (/^[A-D]+$/.test(cleanAnswer)) {
              currentQuestion['正确答案'] = cleanAnswer
              // 根据答案长度判断题目类型
              if (cleanAnswer.length > 1) {
                currentQuestion['题目类型'] = '多选题'
              }
              foundAnswer = true
              console.log('找到答案（格式2）：', cleanAnswer, '题目类型：', currentQuestion['题目类型'])
            }
          }
        }
        
        // 格式3：直接匹配 A、B、C、D
        if (!foundAnswer) {
          const answerMatch3 = line.match(/([A-D,\s;]+)/)
          if (answerMatch3) {
            const cleanAnswer = answerMatch3[1].replace(/[,;\s]/g, '')
            if (/^[A-D]+$/.test(cleanAnswer)) {
              currentQuestion['正确答案'] = cleanAnswer
              // 根据答案长度判断题目类型
              if (cleanAnswer.length > 1) {
                currentQuestion['题目类型'] = '多选题'
              }
              foundAnswer = true
              console.log('找到答案（格式3）：', cleanAnswer, '题目类型：', currentQuestion['题目类型'])
            }
          }
        }
        
        if (!foundAnswer) {
          console.log('未找到有效答案，原始行：', line)
        }
      } else if (line.includes('解析') || line.includes('说明')) {
        // 检测解析
        const analysisMatch = line.match(/[解析说明：]\s*(.+)/)
        if (analysisMatch) {
          currentQuestion['解析'] = analysisMatch[1].trim()
        } else {
          // 如果整行都是解析内容
          currentQuestion['解析'] = line
        }
      } else if (line.includes('难度')) {
        // 检测难度
        const difficultyMatch = line.match(/难度[：\s]*(简单|中等|困难)/)
        if (difficultyMatch) {
          currentQuestion['难度等级'] = difficultyMatch[1]
        }
      } else if (line.length > 10 && !line.match(/^[A-D]/)) {
        // 如果行内容较长且不是选项，可能是题目内容的延续
        if (currentQuestion['题目内容']) {
          currentQuestion['题目内容'] += ' ' + line
        }
      }
    }
  }
  
  // 添加最后一个题目
  if (currentQuestion) {
    // 在添加最后一个题目前，根据答案判断题目类型
    if (currentQuestion['正确答案'] && currentQuestion['正确答案'].length > 1) {
      currentQuestion['题目类型'] = '多选题'
    }
    questions.push(currentQuestion)
  }
  
  // 如果没有解析到题目，尝试其他方法
  if (questions.length === 0) {
    return parseAlternativeFormat(text)
  }
  
  console.log('解析到的题目数量：', questions.length)
  console.log('解析到的题目：', questions)
  return questions
}

// 备用解析方法
const parseAlternativeFormat = (text) => {
  const questions = []
  
  // 尝试按段落分割
  const paragraphs = text.split(/\n\s*\n/).filter(p => p.trim().length > 20)
  
  paragraphs.forEach((paragraph, index) => {
    const lines = paragraph.split('\n').filter(line => line.trim())
    if (lines.length < 3) return // 跳过太短的段落
    
    let question = {
      '题目类型': '单选题',
      '题目内容': '',
      '选项A': '',
      '选项B': '',
      '选项C': '',
      '选项D': '',
      '正确答案': '',
      '解析': '',
      '难度等级': '中等'
    }
    
    let hasOptions = false
    let hasAnswer = false
    
    lines.forEach(line => {
      const trimmedLine = line.trim()
      
      // 第一行通常是题目
      if (!question['题目内容'] && trimmedLine.length > 10) {
        question['题目内容'] = trimmedLine.replace(/^\d+[\.、\s]*/, '')
      }
      // 检测选项
      else if (trimmedLine.match(/^[A-D][\.、\s]/)) {
        const option = trimmedLine.charAt(0)
        const content = trimmedLine.substring(1).replace(/^[\.、\s]+/, '').trim()
        if (content) {
          question[`选项${option}`] = content
          hasOptions = true
        }
      }
             // 检测答案
       else if (trimmedLine.includes('答案') || trimmedLine.includes('正确答案')) {
         console.log('备用方法检测到答案行：', trimmedLine)
         
         // 尝试多种答案格式
         let foundAnswer = false
         
                   // 格式1：答案：A 或 正确答案：A
          const answerMatch1 = trimmedLine.match(/[答案正确答案：]\s*([A-D,\s;]+)/)
          if (answerMatch1) {
            const cleanAnswer = answerMatch1[1].replace(/[,;\s]/g, '')
            if (/^[A-D]+$/.test(cleanAnswer)) {
              question['正确答案'] = cleanAnswer
              // 根据答案长度判断题目类型
              if (cleanAnswer.length > 1) {
                question['题目类型'] = '多选题'
              }
              hasAnswer = true
              foundAnswer = true
              console.log('备用方法找到答案（格式1）：', cleanAnswer, '题目类型：', question['题目类型'])
            }
          }
         
                   // 格式2：答案 A 或 正确答案 A
          if (!foundAnswer) {
            const answerMatch2 = trimmedLine.match(/[答案正确答案]\s+([A-D,\s;]+)/)
            if (answerMatch2) {
              const cleanAnswer = answerMatch2[1].replace(/[,;\s]/g, '')
              if (/^[A-D]+$/.test(cleanAnswer)) {
                question['正确答案'] = cleanAnswer
                // 根据答案长度判断题目类型
                if (cleanAnswer.length > 1) {
                  question['题目类型'] = '多选题'
                }
                hasAnswer = true
                foundAnswer = true
                console.log('备用方法找到答案（格式2）：', cleanAnswer, '题目类型：', question['题目类型'])
              }
            }
          }
         
                   // 格式3：直接匹配 A、B、C、D
          if (!foundAnswer) {
            const answerMatch3 = trimmedLine.match(/([A-D,\s;]+)/)
            if (answerMatch3) {
              const cleanAnswer = answerMatch3[1].replace(/[,;\s]/g, '')
              if (/^[A-D]+$/.test(cleanAnswer)) {
                question['正确答案'] = cleanAnswer
                // 根据答案长度判断题目类型
                if (cleanAnswer.length > 1) {
                  question['题目类型'] = '多选题'
                }
                hasAnswer = true
                foundAnswer = true
                console.log('备用方法找到答案（格式3）：', cleanAnswer, '题目类型：', question['题目类型'])
              }
            }
          }
         
         if (!foundAnswer) {
           console.log('备用方法未找到有效答案，原始行：', trimmedLine)
         }
       }
      // 检测解析
      else if (trimmedLine.includes('解析') || trimmedLine.includes('说明')) {
        question['解析'] = trimmedLine.replace(/^[解析说明：\s]*/, '')
      }
    })
    
         // 只有包含选项和答案的题目才有效
     if (hasOptions && hasAnswer && question['题目内容']) {
       // 根据答案长度判断题目类型
       if (question['正确答案'] && question['正确答案'].length > 1) {
         question['题目类型'] = '多选题'
       }
       questions.push(question)
     }
  })
  
  return questions
}

// 解析 TXT 文档
const parseTextDocument = (text) => {
  return parseWordDocument(text) // 使用相同的解析逻辑
}

// 下一步
const nextStep = async () => {
  if (currentStep.value === 0) {
    // 读取并验证文件
    try {
      const file = fileList.value[0].raw
      const data = await readFile(file)
      previewData.value = validateData(data)
      
      if (validCount.value === 0) {
        ElMessage.error('没有有效的数据可以导入')
        return
      }
      
      currentStep.value = 1
    } catch (error) {
      ElMessage.error('文件读取失败：' + error.message)
    }
  } else if (currentStep.value === 1) {
    currentStep.value = 2
  }
}

// 上一步
const prevStep = () => {
  currentStep.value--
}

// 加载题库列表
const loadQuestionBanks = async () => {
  try {
    const response = await questionBankAPI.getQuestionBanks({ limit: 100 })
    if (response.code === 200) {
      questionBanks.value = response.data.list || []
    }
  } catch (error) {
    console.error('加载题库列表失败:', error)
  }
}

// 加载科目列表
const loadSubjects = async (questionBankId) => {
  try {
    if (!questionBankId) {
      subjects.value = []
      return
    }
    
    const response = await subjectAPI.getSubjects({ 
      questionBankId,
      limit: 100 
    })
    if (response.code === 200) {
      subjects.value = response.data.list || []
    }
  } catch (error) {
    console.error('加载科目列表失败:', error)
  }
}

// 题库选择变化
const onQuestionBankChange = (questionBankId) => {
  importOptions.subjectId = ''
  loadSubjects(questionBankId)
}

// 确认导入
const confirmImport = async () => {
  if (!importOptions.questionBankId) {
    ElMessage.error('请选择题库')
    return
  }
  if (!importOptions.subjectId) {
    ElMessage.error('请选择科目')
    return
  }

  try {
    importing.value = true
    
    // 准备要导入的题目数据
    const questionsToImport = previewData.value
      .filter(item => item.isValid)
      .map(item => ({
        questionBankId: importOptions.questionBankId,
        subjectId: importOptions.subjectId,
        chapter: item.chapter || '',
        type: item.type,
        difficulty: item.difficulty, // 使用题目本身的难度
        content: item.content,
        options: [item.optionA, item.optionB, item.optionC, item.optionD].filter(opt => opt),
        answer: item.answer,
        analysis: item.analysis,
        images: item.images || [] // 添加图片字段
      }))

    // 调用API接口导入题目
    const result = await questionAPI.importQuestions(questionsToImport)

    const selectedBank = questionBanks.value.find(b => b.id === importOptions.questionBankId)
    const selectedSubject = subjects.value.find(s => s.id === importOptions.subjectId)
    
    ElMessage.success(`成功导入 ${questionsToImport.length} 道题目到题库"${selectedBank?.name}"的科目"${selectedSubject?.name}"`)
    
    // 显示错误信息（如果有）
    if (result.data && result.data.errors && result.data.errors.length > 0) {
      console.warn('导入过程中的错误：', result.data.errors)
    }
    
    // 跳转到题库管理页面
    setTimeout(() => {
      router.push('/question-bank-management')
    }, 1500)
    
  } catch (error) {
    console.error('导入错误：', error)
    ElMessage.error('导入失败：' + error.message)
  } finally {
    importing.value = false
  }
}

// 图片URL处理
const getImageUrl = (imagePath) => {
  if (!imagePath || typeof imagePath !== 'string') {
    console.warn('无效的图片路径:', imagePath)
    return ''
  }
  
  // 如果是相对路径，添加服务器地址
  if (imagePath.startsWith('/images/')) {
    return `${getServerUrl()}${imagePath}`
  }
  
  return imagePath
}

// 获取图片预览列表
const getImagePreviewList = (images) => {
  if (!images || !Array.isArray(images)) return []
  return images
    .filter(image => image && typeof image === 'object' && image.path && typeof image.path === 'string')
    .map(image => getImageUrl(image.path))
}

// 组件挂载时加载题库列表
onMounted(() => {
  loadQuestionBanks()
})
</script>

<style scoped>
.question-import {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.import-card {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.import-steps {
  margin-bottom: 30px;
}

.step-content {
  margin-bottom: 30px;
}

.upload-area {
  margin-bottom: 30px;
}

.upload-dragger {
  width: 100%;
}

.upload-icon {
  font-size: 48px;
  color: #c0c4cc;
  margin-bottom: 10px;
}

.upload-text {
  color: #606266;
}

.upload-text em {
  color: #409eff;
  font-style: normal;
}

.upload-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 10px;
}

.template-download {
  margin-bottom: 30px;
}

.template-download h4 {
  margin-bottom: 15px;
  color: #303133;
}

.template-buttons {
  display: flex;
  gap: 15px;
}

.import-guide {
  margin-bottom: 30px;
}

.import-guide h4 {
  margin-bottom: 15px;
  color: #303133;
}

.guide-list {
  margin-top: 15px;
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.guide-list p {
  margin: 8px 0;
  font-size: 14px;
  color: #606266;
}

.guide-list h5 {
  margin: 15px 0 8px 0;
  color: #303133;
  font-size: 14px;
  font-weight: bold;
}

.guide-list pre {
  background-color: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 4px;
  padding: 10px;
  margin: 8px 0;
  font-size: 12px;
  color: #495057;
  white-space: pre-wrap;
  font-family: 'Courier New', monospace;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.preview-stats {
  display: flex;
  gap: 10px;
}

.error-messages {
  margin-top: 20px;
}

.error-messages h4 {
  margin-bottom: 15px;
  color: #f56c6c;
}

.confirm-header {
  text-align: center;
  margin-bottom: 30px;
}

.confirm-header h3 {
  color: #303133;
  margin-bottom: 10px;
}

.confirm-header p {
  color: #606266;
  font-size: 16px;
}

.import-options {
  margin-bottom: 30px;
}

.import-options h4 {
  margin-bottom: 15px;
  color: #303133;
}

.step-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .question-import {
    padding: 10px;
  }
  
  .preview-header {
    flex-direction: column;
    gap: 15px;
  }
  
  .preview-stats {
    flex-wrap: wrap;
  }
  
  .template-buttons {
    flex-direction: column;
  }
  
  .step-actions {
    flex-direction: column;
  }
}
</style>
