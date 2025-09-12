const { ActivationCode, ActivationCodeSubject, Subject, QuestionBank, User } = require('../models/associations');
const { Op } = require('sequelize');

/**
 * 激活码控制器
 */
class ActivationCodeController {
  
  /**
   * 创建激活码
   */
  async createActivationCode(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      const { name, description, subjectIds, expiresAt } = ctx.request.body;
      
      if (!name || !subjectIds || !Array.isArray(subjectIds) || subjectIds.length === 0) {
        ctx.body = { code: 400, message: '请提供激活码名称和至少一个科目' };
        return;
      }

      // 生成激活码
      const code = ActivationCodeController.generateActivationCode();
      
      // 验证科目是否存在
      const subjects = await Subject.findAll({
        where: { id: { [Op.in]: subjectIds } }
      });
      
      if (subjects.length !== subjectIds.length) {
        ctx.body = { code: 400, message: '部分科目不存在' };
        return;
      }

      // 创建激活码
      const activationCode = await ActivationCode.create({
        code,
        name,
        description,
        status: 'active',
        expiresAt: expiresAt ? new Date(expiresAt) : null,
        createdBy: userId
      });

      // 关联科目
      await activationCode.setSubjects(subjects);

      // 获取完整的激活码信息
      const result = await ActivationCode.findByPk(activationCode.id, {
        include: [
          {
            model: Subject,
            as: 'subjects',
            include: [
              {
                model: QuestionBank,
                as: 'questionBank',
                attributes: ['id', 'name']
              }
            ]
          }
        ]
      });

      ctx.body = {
        code: 200,
        message: '激活码创建成功',
        data: result
      };
    } catch (error) {
      console.error('创建激活码失败:', error);
      ctx.body = {
        code: 500,
        message: '创建激活码失败: ' + error.message
      };
    }
  }

  /**
   * 获取激活码列表
   */
  async getActivationCodes(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      const { page = 1, limit = 10, status, search } = ctx.query;
      const offset = (page - 1) * limit;

      const where = {};
      if (status) {
        where.status = status;
      }
      if (search) {
        where[Op.or] = [
          { name: { [Op.like]: `%${search}%` } },
          { code: { [Op.like]: `%${search}%` } }
        ];
      }

      const { rows, count } = await ActivationCode.findAndCountAll({
        where,
        include: [
          {
            model: User,
            as: 'user',
            attributes: ['id', 'phone_number', 'email'],
            required: false
          },
          {
            model: Subject,
            as: 'subjects',
            include: [
              {
                model: QuestionBank,
                as: 'questionBank',
                attributes: ['id', 'name']
              }
            ]
          }
        ],
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['createdAt', 'DESC']]
      });

      ctx.body = {
        code: 200,
        message: '获取激活码列表成功',
        data: {
          list: rows,
          total: count,
          page: parseInt(page),
          limit: parseInt(limit)
        }
      };
    } catch (error) {
      console.error('获取激活码列表失败:', error);
      ctx.body = {
        code: 500,
        message: '获取激活码列表失败: ' + error.message
      };
    }
  }

  /**
   * 获取激活码详情
   */
  async getActivationCodeById(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      const { id } = ctx.params;
      
      const activationCode = await ActivationCode.findByPk(id, {
        include: [
          {
            model: User,
            as: 'user',
            attributes: ['id', 'phone_number', 'email'],
            required: false
          },
          {
            model: Subject,
            as: 'subjects',
            include: [
              {
                model: QuestionBank,
                as: 'questionBank',
                attributes: ['id', 'name']
              }
            ]
          }
        ]
      });

      if (!activationCode) {
        ctx.body = { code: 404, message: '激活码不存在' };
        return;
      }

      ctx.body = {
        code: 200,
        message: '获取激活码详情成功',
        data: activationCode
      };
    } catch (error) {
      console.error('获取激活码详情失败:', error);
      ctx.body = {
        code: 500,
        message: '获取激活码详情失败: ' + error.message
      };
    }
  }

  /**
   * 更新激活码
   */
  async updateActivationCode(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      const { id } = ctx.params;
      const { name, description, subjectIds, status, expiresAt } = ctx.request.body;

      const activationCode = await ActivationCode.findByPk(id);
      if (!activationCode) {
        ctx.body = { code: 404, message: '激活码不存在' };
        return;
      }

      // 检查权限（只有创建者可以修改）
      if (activationCode.createdBy !== userId) {
        ctx.body = { code: 403, message: '无权限修改此激活码' };
        return;
      }

      // 更新基本信息
      const updateData = {};
      if (name !== undefined) updateData.name = name;
      if (description !== undefined) updateData.description = description;
      if (status !== undefined) updateData.status = status;
      if (expiresAt !== undefined) updateData.expiresAt = expiresAt ? new Date(expiresAt) : null;

      await activationCode.update(updateData);

      // 更新关联科目
      if (subjectIds && Array.isArray(subjectIds)) {
        const subjects = await Subject.findAll({
          where: { id: { [Op.in]: subjectIds } }
        });
        await activationCode.setSubjects(subjects);
      }

      // 获取更新后的完整信息
      const result = await ActivationCode.findByPk(id, {
        include: [
          {
            model: User,
            as: 'user',
            attributes: ['id', 'phone_number', 'email'],
            required: false
          },
          {
            model: Subject,
            as: 'subjects',
            include: [
              {
                model: QuestionBank,
                as: 'questionBank',
                attributes: ['id', 'name']
              }
            ]
          }
        ]
      });

      ctx.body = {
        code: 200,
        message: '更新激活码成功',
        data: result
      };
    } catch (error) {
      console.error('更新激活码失败:', error);
      ctx.body = {
        code: 500,
        message: '更新激活码失败: ' + error.message
      };
    }
  }

  /**
   * 删除激活码
   */
  async deleteActivationCode(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      const { id } = ctx.params;

      const activationCode = await ActivationCode.findByPk(id);
      if (!activationCode) {
        ctx.body = { code: 404, message: '激活码不存在' };
        return;
      }

      // 检查权限（只有创建者可以删除）
      if (activationCode.createdBy !== userId) {
        ctx.body = { code: 403, message: '无权限删除此激活码' };
        return;
      }

      // 删除激活码（会级联删除关联关系）
      await activationCode.destroy();

      ctx.body = {
        code: 200,
        message: '删除激活码成功'
      };
    } catch (error) {
      console.error('删除激活码失败:', error);
      ctx.body = {
        code: 500,
        message: '删除激活码失败: ' + error.message
      };
    }
  }

  /**
   * 小程序端：验证激活码
   */
  async verifyActivationCode(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '请先登录' };
        return;
      }

      const { code } = ctx.request.body;
      
      if (!code) {
        ctx.body = { code: 400, message: '请提供激活码' };
        return;
      }

      // 查找激活码
      const activationCode = await ActivationCode.findOne({
        where: { code },
        include: [
          {
            model: Subject,
            as: 'subjects',
            include: [
              {
                model: QuestionBank,
                as: 'questionBank',
                attributes: ['id', 'name']
              }
            ]
          }
        ]
      });

      if (!activationCode) {
        ctx.body = { code: 404, message: '激活码不存在' };
        return;
      }

      // 检查状态
      if (activationCode.status !== 'active') {
        ctx.body = { code: 400, message: '激活码已失效' };
        return;
      }

      // 检查是否过期
      if (activationCode.expiresAt && new Date() > activationCode.expiresAt) {
        ctx.body = { code: 400, message: '激活码已过期' };
        return;
      }

      // 检查是否已被使用
      if (activationCode.userId && activationCode.userId !== userId) {
        ctx.body = { code: 400, message: '激活码已被其他用户使用' };
        return;
      }

      // 绑定用户
      if (!activationCode.userId) {
        await activationCode.update({
          userId: userId,
          usedAt: new Date(),
          status: 'used'
        });
      }

      ctx.body = {
        code: 200,
        message: '激活码验证成功',
        data: {
          activationCode: {
            id: activationCode.id,
            name: activationCode.name,
            description: activationCode.description
          },
          subjects: activationCode.subjects
        }
      };
    } catch (error) {
      console.error('验证激活码失败:', error);
      ctx.body = {
        code: 500,
        message: '验证激活码失败: ' + error.message
      };
    }
  }

  /**
   * 小程序端：获取用户已激活的科目
   */
  async getUserActivatedSubjects(ctx) {
    try {
      const userId = ctx.state.user?.id;
      if (!userId) {
        ctx.body = { code: 401, message: '未提供认证token' };
        return;
      }

      // 获取用户已激活的科目
      const activationCodes = await ActivationCode.findAll({
        where: {
          userId: userId,
          status: 'used'
        },
        include: [
          {
            model: Subject,
            as: 'subjects',
            include: [
              {
                model: QuestionBank,
                as: 'questionBank',
                attributes: ['id', 'name']
              }
            ]
          }
        ]
      });

      // 合并所有科目
      const subjects = [];
      activationCodes.forEach(code => {
        subjects.push(...code.subjects);
      });

      // 去重
      const uniqueSubjects = subjects.filter((subject, index, self) => 
        index === self.findIndex(s => s.id === subject.id)
      );

      ctx.body = {
        code: 200,
        message: '获取已激活科目成功',
        data: uniqueSubjects
      };
    } catch (error) {
      console.error('获取已激活科目失败:', error);
      ctx.body = {
        code: 500,
        message: '获取已激活科目失败: ' + error.message
      };
    }
  }

  /**
   * 生成激活码
   */
  static generateActivationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let result = '';
    for (let i = 0; i < 8; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }
}

module.exports = new ActivationCodeController();
