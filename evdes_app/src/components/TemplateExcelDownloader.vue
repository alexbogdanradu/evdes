<template>
    <button
        class="px-4 py-2 bg-blue-600 hover:bg-blue-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
        @click="downloadTemplateExcel">Export template Excel</button>
</template>

<script>
import XlsxPopulate from 'xlsx-populate/browser/xlsx-populate';
import JSZip from 'jszip';
import { saveAs } from 'file-saver';

const MONTHS = [
    'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
    'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie',
];

export default {
    name: 'TemplateExcelDownloader',
    props: {
        wasteList: {
            type: Array,
            required: true,
        },
        year: {
            type: String,
            required: true,
        },
    },
    methods: {
        async loadTemplateBuffer() {
            const baseUrl = import.meta.env.BASE_URL || '/';
            const candidates = [
                `${baseUrl}templateEvdes.xlsx`,
                `${baseUrl}templateEvdes.xls`,
            ];

            for (const url of candidates) {
                const response = await fetch(url);
                if (response.ok) {
                    return response.arrayBuffer();
                }
            }

            throw new Error('Failed to fetch template');
        },

        filterByYearAndCode(wasteList, year) {
            const numericYear = parseInt(year, 10);
            const result = {};
            wasteList.forEach((item) => {
                if (item.year === numericYear) {
                    if (!result[item.code]) result[item.code] = [];
                    result[item.code].push(item);
                }
            });
            return result;
        },

        sanitizeSheetName(raw) {
            const cleaned = String(raw || '').replace(/[\\/*?:\[\]]/g, '_').trim();
            return (cleaned || 'Sheet').substring(0, 31);
        },

        setCellValue(sheet, addr, value) {
            sheet.cell(addr).value(value ?? 0);
        },

        encodeXml(value) {
            return String(value ?? '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&apos;');
        },

        calcMonthlyTotals(wasteData) {
            return MONTHS.map((month) => {
                const monthItems = wasteData.filter((item) => item.month === month);
                const generated = monthItems.reduce((s, i) => s + i.quantity, 0);
                const valorificat = monthItems.reduce((s, i) => s + i.outbound.Valorificat.quantity, 0);
                const eliminat = monthItems.reduce((s, i) => s + i.outbound.Eliminat.quantity, 0);
                const stocat = monthItems.reduce((s, i) => s + i.outbound.Stocat.quantity, 0);
                const tratat = monthItems.reduce((s, i) => s + i.outbound.Tratat.quantity, 0);
                const ramas = generated - valorificat - eliminat;
                return { month, generated, valorificat, eliminat, stocat, tratat, ramas };
            });
        },

        fillWasteSheet(sheet, wasteData) {
            const firstItem = wasteData[0];
            if (!firstItem) return;

            const totals = this.calcMonthlyTotals(wasteData);

            totals.forEach((t, idx) => {
                const row = 16 + idx;

                this.setCellValue(sheet, `C${row}`, t.generated);
                this.setCellValue(sheet, `E${row}`, t.valorificat);
                this.setCellValue(sheet, `G${row}`, t.eliminat);
                this.setCellValue(sheet, `I${row}`, t.ramas);
                this.setCellValue(sheet, `M${row}`, t.valorificat);

                const row2 = 36 + idx;
                this.setCellValue(sheet, `D${row2}`, t.stocat);
                this.setCellValue(sheet, `F${row2}`, t.tratat);
                this.setCellValue(sheet, `N${row2}`, t.eliminat);
            });

            const totalGenerated = totals.reduce((s, t) => s + t.generated, 0);
            const totalValorificat = totals.reduce((s, t) => s + t.valorificat, 0);
            const totalEliminat = totals.reduce((s, t) => s + t.eliminat, 0);
            const totalStocat = totals.reduce((s, t) => s + t.stocat, 0);
            const totalTratat = totals.reduce((s, t) => s + t.tratat, 0);
            const totalRamas = totals.reduce((s, t) => s + t.ramas, 0);

            this.setCellValue(sheet, 'C28', totalGenerated);
            this.setCellValue(sheet, 'E28', totalValorificat);
            this.setCellValue(sheet, 'G28', totalEliminat);
            this.setCellValue(sheet, 'I28', totalRamas);
            this.setCellValue(sheet, 'M28', totalValorificat);

            this.setCellValue(sheet, 'D48', totalStocat);
            this.setCellValue(sheet, 'F48', totalTratat);
            this.setCellValue(sheet, 'N48', totalEliminat);
        },

        copyRowCells(sheet, sourceRow, targetRow, fromCol = 'A', toCol = 'N') {
            const start = fromCol.charCodeAt(0);
            const end = toCol.charCodeAt(0);
            for (let c = start; c <= end; c++) {
                const col = String.fromCharCode(c);
                const src = sheet.cell(`${col}${sourceRow}`);
                const dst = sheet.cell(`${col}${targetRow}`);
                dst.value(src.value());
                dst.formula(src.formula());
                dst.style(src.style());
            }
            sheet.row(targetRow).height(sheet.row(sourceRow).height());
            sheet.row(targetRow).hidden(sheet.row(sourceRow).hidden());
        },

        insertStyledRowsForYearSheet(sheet, extraRows) {
            if (extraRows <= 0) return;

            const used = sheet.usedRange();
            const maxRow = used.endCell().rowNumber();
            const shiftFromRow = 10;

            for (let r = maxRow; r >= shiftFromRow; r--) {
                this.copyRowCells(sheet, r, r + extraRows, 'A', 'N');
            }

            for (let i = 0; i < extraRows; i++) {
                this.copyRowCells(sheet, 9, 10 + i, 'A', 'N');
            }

            const oldNoteRow = 11;
            const newNoteRow = oldNoteRow + extraRows;
            try {
                sheet.range(`B${oldNoteRow}:F${oldNoteRow}`).merged(false);
            } catch (err) {
                // ignore if not merged in source template
            }
            sheet.range(`B${newNoteRow}:F${newNoteRow}`).merged(true);
        },

        fillYearSheet(sheet, groupedData, wasteCodes) {
            this.insertStyledRowsForYearSheet(sheet, Math.max(0, wasteCodes.length - 1));

            sheet.cell('B2').value(`si stocare deseuri An  ${this.year}`);
            sheet.cell('B3').value('Agent economic: ');
            sheet.cell('B14').value('');

            wasteCodes.forEach((code, idx) => {
                const wasteData = groupedData[code];
                const firstItem = wasteData[0];
                const row = 9 + idx;

                const totalGenerated = wasteData.reduce((s, i) => s + i.quantity, 0);
                const totalValorificat = wasteData.reduce((s, i) => s + i.outbound.Valorificat.quantity, 0);
                const totalEliminat = wasteData.reduce((s, i) => s + i.outbound.Eliminat.quantity, 0);
                const stocInceput = 0;
                const stocSfarsit = stocInceput + totalGenerated - totalValorificat - totalEliminat;

                this.setCellValue(sheet, `B${row}`, firstItem.name || '');
                this.setCellValue(sheet, `C${row}`, code);
                this.setCellValue(sheet, `D${row}`, stocInceput);
                this.setCellValue(sheet, `E${row}`, totalGenerated);
                this.setCellValue(sheet, `F${row}`, totalValorificat);
                this.setCellValue(sheet, `G${row}`, totalEliminat);
                this.setCellValue(sheet, `H${row}`, stocSfarsit);
            });
        },

        async patchDrawingPlaceholders(arrayBuffer, sheetPayloadByName) {
            const zip = await JSZip.loadAsync(arrayBuffer);

            const readText = async (path) => {
                const file = zip.file(path);
                if (!file) return null;
                return file.async('string');
            };

            const workbookXml = await readText('xl/workbook.xml');
            const workbookRelsXml = await readText('xl/_rels/workbook.xml.rels');
            if (!workbookXml || !workbookRelsXml) {
                return arrayBuffer;
            }

            const relToWorksheet = {};
            workbookRelsXml.replace(/<Relationship[^>]*Id="([^"]+)"[^>]*Target="([^"]+)"/g, (_, id, target) => {
                relToWorksheet[id] = `xl/${target.replace(/^\/+/, '')}`;
                return _;
            });

            const sheetToWorksheet = {};
            workbookXml.replace(/<sheet[^>]*name="([^"]+)"[^>]*r:id="([^"]+)"/g, (_, name, relId) => {
                sheetToWorksheet[name] = relToWorksheet[relId];
                return _;
            });

            const resolveTarget = (basePath, target) => {
                const baseParts = basePath.split('/').slice(0, -1);
                const targetParts = target.split('/');
                const out = [...baseParts];
                targetParts.forEach((part) => {
                    if (!part || part === '.') return;
                    if (part === '..') out.pop();
                    else out.push(part);
                });
                return out.join('/');
            };

            const replaceAll = (input, replacements) => {
                let out = input;
                Object.entries(replacements).forEach(([key, value]) => {
                    out = out.split(key).join(this.encodeXml(value));
                });
                return out;
            };

            for (const [sheetName, payload] of Object.entries(sheetPayloadByName)) {
                const worksheetPath = sheetToWorksheet[sheetName];
                if (!worksheetPath) continue;

                const worksheetXml = await readText(worksheetPath);
                if (!worksheetXml) continue;

                const drawingRelMatch = worksheetXml.match(/<drawing[^>]*r:id="([^"]+)"/);
                if (!drawingRelMatch) continue;

                const worksheetFileName = worksheetPath.split('/').pop();
                const relsPath = `xl/worksheets/_rels/${worksheetFileName}.rels`;
                const relsXml = await readText(relsPath);
                if (!relsXml) continue;

                const drawingRelId = drawingRelMatch[1];
                const drawingTargetMatch = relsXml.match(new RegExp(`<Relationship[^>]*Id="${drawingRelId}"[^>]*Target="([^"]+)"`));
                if (!drawingTargetMatch) continue;

                const drawingPath = resolveTarget(relsPath, drawingTargetMatch[1]);
                const drawingXml = await readText(drawingPath);
                if (!drawingXml) continue;

                const replacements = {
                    '%WASTE_TEXT%': payload.wasteText,
                    '%WASTE_CODE%': payload.wasteCode,
                    '%WASTE_UOM%': payload.wasteUom,
                    '%WASTE_STATE%': 'Solida',
                    '%YEAR%': this.year,
                    '%AGENT_ECONOMIC%': payload.agentEconomic || '',
                };

                const patchedDrawingXml = replaceAll(drawingXml, replacements);
                zip.file(drawingPath, patchedDrawingXml);
            }

            const output = await zip.generateAsync({ type: 'arraybuffer' });
            return output;
        },

        async downloadTemplateExcel() {
            try {
                const templateBuffer = await this.loadTemplateBuffer();

                const workbook = await XlsxPopulate.fromDataAsync(templateBuffer);

                const groupedData = this.filterByYearAndCode(this.wasteList, this.year);
                const wasteCodes = Object.keys(groupedData);

                if (wasteCodes.length === 0) {
                    alert('Nu există date pentru anul selectat.');
                    return;
                }

                const wasteSheetPayload = {};
                const templateWasteSheet = workbook.sheet('WASTE');
                const templateYearSheet = workbook.sheet('YEAR');

                if (!templateWasteSheet || !templateYearSheet) {
                    throw new Error('Template-ul trebuie sa contina foile WASTE si YEAR.');
                }

                wasteCodes.forEach((code, index) => {
                    const sheetName = this.sanitizeSheetName(code);
                    const targetSheet = index === 0
                        ? templateWasteSheet.name(sheetName)
                        : workbook.cloneSheet(templateWasteSheet, sheetName);

                    this.fillWasteSheet(targetSheet, groupedData[code]);

                    const firstItem = groupedData[code][0] || {};
                    wasteSheetPayload[sheetName] = {
                        wasteText: firstItem.name || '',
                        wasteCode: firstItem.code || code,
                        wasteUom: firstItem.unit || '',
                        agentEconomic: '',
                    };
                });

                templateYearSheet.name(`Rep ${this.year}`);
                this.fillYearSheet(templateYearSheet, groupedData, wasteCodes);

                const rawOutput = await workbook.outputAsync({ type: 'arraybuffer' });
                const patchedOutput = await this.patchDrawingPlaceholders(rawOutput, wasteSheetPayload);

                const blob = new Blob([patchedOutput], {
                    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                });
                saveAs(blob, `raport-evdes-${this.year}.xlsx`);
            } catch (err) {
                console.error('Template export error:', err);
                alert('Eroare la exportul pe baza de template: ' + err.message);
            }
        },

    },
};
</script>
