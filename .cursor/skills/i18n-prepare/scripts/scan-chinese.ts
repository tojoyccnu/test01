#!/usr/bin/env npx tsx
/**
 * 中文硬编码扫描脚本
 *
 * 扫描指定目录下的 Vue/TS 文件，识别硬编码中文字符串，
 * 生成结构化报告供 AI 分批处理。
 *
 * 用法：
 *   npx tsx .cursor/skills/i18n-prepare/scripts/scan-chinese.ts [target-dir]
 *   npx tsx .cursor/skills/i18n-prepare/scripts/scan-chinese.ts src/views
 *
 * 输出：
 *   .cursor/skills/i18n-prepare/scripts/i18n-scan-report.json
 */
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// 类型定义
// ============================================================================

interface FileResult {
  path: string;
  relativePath: string;
  count: number;
  strings: ChineseString[];
}

interface ChineseString {
  text: string;
  line: number;
  column: number;
  context: 'template' | 'script' | 'style';
  type: 'text' | 'attribute' | 'string-literal';
}

interface ModuleResult {
  name: string;
  fileCount: number;
  chineseCount: number;
  files: { path: string; count: number }[];
}

interface ScanReport {
  scanTime: string;
  targetDirectory: string;
  summary: {
    totalFiles: number;
    filesWithChinese: number;
    totalChineseStrings: number;
  };
  modules: Record<string, ModuleResult>;
  fileDetails: FileResult[];
}

// ============================================================================
// 配置
// ============================================================================

const CHINESE_REGEX = /[\u4e00-\u9fff\u3000-\u303f\uff00-\uffef]{2,}/g;

// 排除模式
const EXCLUDE_PATTERNS = {
  // 注释
  singleLineComment: /\/\/.*$/gm,
  multiLineComment: /\/\*[\s\S]*?\*\//g,
  htmlComment: /<!--[\s\S]*?-->/g,

  // console 日志
  consoleLog: /console\.(log|warn|error|info|debug)\s*\([^)]*\)/g,

  // 已国际化内容
  i18nCall: /\$t[c]?\s*\([^)]*\)|i18n\.t[c]?\s*\([^)]*\)/g,

  // 导入语句
  importStatement: /import\s+.*\s+from\s+['"][^'"]+['"]/g,
};

// 文件扩展名
const FILE_EXTENSIONS = ['.vue', '.ts'];

// 忽略目录
const IGNORE_DIRS = ['node_modules', 'dist', '.git', '.cursor'];

// 忽略文件模式
const IGNORE_FILE_PATTERNS = [
  /\.stories\.(ts|tsx|js|jsx)$/, // Storybook story 文件
  /\.story\.(ts|tsx|js|jsx)$/, // Storybook story 文件（单数形式）
  /\.test\.(ts|tsx|js|jsx|vue)$/, // 测试文件
  /\.spec\.(ts|tsx|js|jsx|vue)$/, // 测试文件（spec 形式）
  /__tests__/, // Jest 测试目录中的文件
];

// ============================================================================
// 工具函数
// ============================================================================

// oxlint-disable-next-line oxc/only-used-in-recursion
function getAllFiles(dir: string, baseDir: string): string[] {
  const files: string[] = [];

  if (!fs.existsSync(dir)) {
    console.error(`目录不存在: ${dir}`);
    return files;
  }

  const items = fs.readdirSync(dir, { withFileTypes: true });

  for (const item of items) {
    const fullPath = path.join(dir, item.name);

    if (item.isDirectory()) {
      if (!IGNORE_DIRS.includes(item.name)) {
        files.push(...getAllFiles(fullPath, baseDir));
      }
    } else if (item.isFile()) {
      const ext = path.extname(item.name);
      if (FILE_EXTENSIONS.includes(ext)) {
        // 检查是否匹配忽略模式
        const shouldIgnore = IGNORE_FILE_PATTERNS.some(pattern => pattern.test(item.name));
        if (!shouldIgnore) {
          files.push(fullPath);
        }
      }
    }
  }

  return files;
}

function removeExcludedContent(content: string): string {
  let cleaned = content;

  // 移除注释
  cleaned = cleaned.replace(EXCLUDE_PATTERNS.htmlComment, ' ');
  cleaned = cleaned.replace(EXCLUDE_PATTERNS.multiLineComment, ' ');
  cleaned = cleaned.replace(EXCLUDE_PATTERNS.singleLineComment, ' ');

  // 移除 console 日志
  cleaned = cleaned.replace(EXCLUDE_PATTERNS.consoleLog, ' ');

  // 移除已国际化内容
  cleaned = cleaned.replace(EXCLUDE_PATTERNS.i18nCall, ' ');

  // 移除导入语句
  cleaned = cleaned.replace(EXCLUDE_PATTERNS.importStatement, ' ');

  return cleaned;
}

function detectContext(content: string, position: number): 'template' | 'script' | 'style' {
  const beforePos = content.substring(0, position);

  // 检查是否在 <style> 中
  const lastStyleOpen = beforePos.lastIndexOf('<style');
  const lastStyleClose = beforePos.lastIndexOf('</style>');
  if (lastStyleOpen > lastStyleClose) {
    return 'style';
  }

  // 检查是否在 <script> 中
  const lastScriptOpen = beforePos.lastIndexOf('<script');
  const lastScriptClose = beforePos.lastIndexOf('</script>');
  if (lastScriptOpen > lastScriptClose) {
    return 'script';
  }

  return 'template';
}

function getLineAndColumn(content: string, position: number): { line: number; column: number } {
  const lines = content.substring(0, position).split('\n');
  return {
    line: lines.length,
    column: lines[lines.length - 1].length + 1,
  };
}

function detectStringType(
  content: string,
  match: RegExpExecArray
): 'text' | 'attribute' | 'string-literal' {
  const beforeMatch = content.substring(Math.max(0, match.index - 50), match.index);

  // 检查是否是属性值 (attribute="中文")
  if (/=\s*["']\s*$/.test(beforeMatch)) {
    return 'attribute';
  }

  // 检查是否在引号中 (字符串字面量)
  if (/["'`]\s*$/.test(beforeMatch)) {
    return 'string-literal';
  }

  return 'text';
}

function scanFile(filePath: string, baseDir: string): FileResult | null {
  const content = fs.readFileSync(filePath, 'utf-8');
  const cleanedContent = removeExcludedContent(content);

  const strings: ChineseString[] = [];
  let match: RegExpExecArray | null;

  // 重置正则表达式
  CHINESE_REGEX.lastIndex = 0;

  while ((match = CHINESE_REGEX.exec(cleanedContent)) !== null) {
    const context = detectContext(content, match.index);

    // 跳过 style 中的中文（通常是伪元素 content）
    if (context === 'style') {
      continue;
    }

    const { line, column } = getLineAndColumn(content, match.index);
    const type = detectStringType(content, match);

    strings.push({
      text: match[0],
      line,
      column,
      context,
      type,
    });
  }

  if (strings.length === 0) {
    return null;
  }

  return {
    path: filePath,
    relativePath: path.relative(baseDir, filePath),
    count: strings.length,
    strings,
  };
}

function getModuleName(relativePath: string): string {
  const parts = relativePath.split(path.sep);

  // src/views/{module}/... -> module
  if (parts[0] === 'src' && parts[1] === 'views' && parts.length > 2) {
    return parts[2];
  }

  // src/components/... -> components
  if (parts[0] === 'src' && parts[1] === 'components') {
    return 'components';
  }

  // src/utils/... -> utils
  if (parts[0] === 'src' && parts[1] === 'utils') {
    return 'utils';
  }

  // src/hooks/... -> hooks
  if (parts[0] === 'src' && parts[1] === 'hooks') {
    return 'hooks';
  }

  // 其他情况
  return 'other';
}

function groupByModule(fileResults: FileResult[]): Record<string, ModuleResult> {
  const modules: Record<string, ModuleResult> = {};

  for (const file of fileResults) {
    const moduleName = getModuleName(file.relativePath);

    if (!modules[moduleName]) {
      modules[moduleName] = {
        name: moduleName,
        fileCount: 0,
        chineseCount: 0,
        files: [],
      };
    }

    modules[moduleName].fileCount++;
    modules[moduleName].chineseCount += file.count;
    modules[moduleName].files.push({
      path: file.relativePath,
      count: file.count,
    });
  }

  // 按中文数量降序排序每个模块内的文件
  for (const module of Object.values(modules)) {
    module.files.sort((a, b) => b.count - a.count);
  }

  return modules;
}

// ============================================================================
// 主函数
// ============================================================================

function main(): void {
  const args = process.argv.slice(2);
  const targetDir = args[0] || 'src';

  // 解析目标目录
  const workspaceRoot = process.cwd();
  const absoluteTargetDir = path.isAbsolute(targetDir)
    ? targetDir
    : path.join(workspaceRoot, targetDir);

  console.log(`\n🔍 开始扫描中文硬编码...`);
  console.log(`   目标目录: ${absoluteTargetDir}\n`);

  // 获取所有文件
  const files = getAllFiles(absoluteTargetDir, workspaceRoot);
  console.log(`   找到 ${files.length} 个 Vue/TS 文件`);

  // 扫描每个文件
  const fileResults: FileResult[] = [];
  let totalStrings = 0;

  for (const file of files) {
    const result = scanFile(file, workspaceRoot);
    if (result) {
      fileResults.push(result);
      totalStrings += result.count;
    }
  }

  // 按模块分组
  const modules = groupByModule(fileResults);

  // 生成报告
  const report: ScanReport = {
    scanTime: new Date().toISOString(),
    targetDirectory: targetDir,
    summary: {
      totalFiles: files.length,
      filesWithChinese: fileResults.length,
      totalChineseStrings: totalStrings,
    },
    modules,
    fileDetails: fileResults,
  };

  // 输出报告
  const reportPath = path.join(
    workspaceRoot,
    '.cursor/skills/i18n-prepare/scripts/i18n-scan-report.json'
  );

  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2), 'utf-8');

  // 打印摘要
  console.log(`\n📊 扫描完成！\n`);
  console.log(`   总文件数: ${report.summary.totalFiles}`);
  console.log(`   包含中文的文件: ${report.summary.filesWithChinese}`);
  console.log(`   中文字符串总数: ${report.summary.totalChineseStrings}`);
  console.log(`\n📦 按模块统计:\n`);

  const sortedModules = Object.values(modules).sort((a, b) => b.chineseCount - a.chineseCount);

  for (const module of sortedModules) {
    console.log(`   ${module.name}: ${module.fileCount} 文件, ${module.chineseCount} 处中文`);
  }

  console.log(`\n📄 报告已保存至: ${reportPath}\n`);
}

main();
