<template>
    <button
        class="px-4 py-2 bg-green-500 hover:bg-green-100 hover:text-black text-white font-semibold rounded shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
        @click="downloadExcel">Export catre Excel</button>
</template>

<script>
import ExcelJS from 'exceljs';
import { saveAs } from 'file-saver';

export default {
    name: 'ExcelDownloader',
    props: {
        wasteList: {
            type: Array,
            required: true,
        },
        year: {
            type: String,
            required: true
        }
    },
    methods: {
        filterWasteListByYearAndCode(wasteList, year) {
            const numericYear = parseInt(year, 10); // Convert year to a number
            const filteredData = {};
            wasteList.forEach((item) => {
                if (item.year === numericYear) {
                    if (!filteredData[item.code]) {
                        filteredData[item.code] = [];
                    }
                    filteredData[item.code].push(item);
                }
            });
            return filteredData;
        },

        generateThirdTable(worksheet, wasteData) {
            // Add 3 blank rows before Chapter 3
            worksheet.addRow([]);
            worksheet.addRow([]);
            worksheet.addRow([]);

            // Add title for Chapter 3
            const chapterTitleRow = worksheet.addRow(['CAPITOLUL 3: Valorificarea deseurilor']);
            chapterTitleRow.font = { bold: true };
            worksheet.mergeCells(`A${chapterTitleRow.number}:D${chapterTitleRow.number}`);
            worksheet.getCell(`A${chapterTitleRow.number}`).alignment = { horizontal: 'center', vertical: 'middle' };

            // Add headers
            worksheet.addRow([
                'Luna',
                'Cantitatea de deseuri',
                'Operatiunea de valorificare, conf. Anexei II Legea 211/2011',
                'Agentul economic care efectueaza operatia de valorificare',
            ]);

            const headerRow = worksheet.lastRow; // Get the last added row (the header row)
            headerRow.font = { bold: true }; // Make headers bold

            // Style the headers
            worksheet.getRow(headerRow).eachCell({ includeEmpty: true }, (cell) => {
                cell.alignment = { horizontal: 'center', vertical: 'middle' };
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });

            // Add data rows
            const months = [
                'Ianuarie',
                'Februarie',
                'Martie',
                'Aprilie',
                'Mai',
                'Iunie',
                'Iulie',
                'August',
                'Septembrie',
                'Octombrie',
                'Noiembrie',
                'Decembrie',
            ];

            months.forEach((month) => {
                const monthData = wasteData.filter((item) => item.month === month);
                const valorificata = monthData.reduce((sum, item) => sum + item.outbound.Valorificat.quantity, 0);

                const row = worksheet.addRow([
                    month,
                    valorificata,
                    '', // Placeholder for "Operatiunea de valorificare"
                    '', // Placeholder for "Agentul economic"
                ]);

                // Style the data cells
                row.eachCell({ includeEmpty: true }, (cell) => {
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' },
                    };
                    cell.alignment = { horizontal: 'center', vertical: 'middle' };
                });
            });

            // Add a total row
            const totalRow = worksheet.addRow([
                'Total an',
                wasteData.reduce((sum, item) => sum + item.outbound.Valorificat.quantity, 0), // Total valorificata
                '',
                '',
            ]);
            totalRow.font = { bold: true };
            totalRow.eachCell({ includeEmpty: true }, (cell) => {
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });
        },

        generateFourthTable(worksheet, wasteData) {
            // Add 3 blank rows before Chapter 4
            worksheet.addRow([]);
            worksheet.addRow([]);
            worksheet.addRow([]);

            // Add title for Chapter 4
            const chapterTitleRow = worksheet.addRow(['CAPITOLUL 4: Eliminarea deseurilor']);
            chapterTitleRow.font = { bold: true };
            worksheet.mergeCells(`A${chapterTitleRow.number}:D${chapterTitleRow.number}`);
            worksheet.getCell(`A${chapterTitleRow.number}`).alignment = { horizontal: 'center', vertical: 'middle' };

            // Add headers
            worksheet.addRow([
                'Luna',
                'Cantitatea de deseuri',
                'Operatiunea de eliminare, conf. Anexei II Legea 211/2011',
                'Agentul economic care efectueaza operatia de eliminare',
            ]);
            const headerRow = worksheet.lastRow.number;
            worksheet.getRow(headerRow).font = { bold: true };

            // Style the headers
            worksheet.getRow(headerRow).eachCell({ includeEmpty: true }, (cell) => {
                cell.alignment = { horizontal: 'center', vertical: 'middle' };
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });

            // Add data rows
            const months = [
                'Ianuarie',
                'Februarie',
                'Martie',
                'Aprilie',
                'Mai',
                'Iunie',
                'Iulie',
                'August',
                'Septembrie',
                'Octombrie',
                'Noiembrie',
                'Decembrie',
            ];

            months.forEach((month) => {
                const monthData = wasteData.filter((item) => item.month === month);
                const eliminata = monthData.reduce((sum, item) => sum + item.outbound.Eliminat.quantity, 0);

                const row = worksheet.addRow([
                    month,
                    eliminata,
                    '', // Placeholder for "Operatiunea de eliminare"
                    '', // Placeholder for "Agentul economic"
                ]);

                // Style the data cells
                row.eachCell({ includeEmpty: true }, (cell) => {
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' },
                    };
                    cell.alignment = { horizontal: 'center', vertical: 'middle' };
                });
            });

            // Add a total row
            const totalRow = worksheet.addRow([
                'Total an',
                wasteData.reduce((sum, item) => sum + item.outbound.Eliminat.quantity, 0), // Total eliminata
                '',
                '',
            ]);
            totalRow.font = { bold: true };
            totalRow.eachCell({ includeEmpty: true }, (cell) => {
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });
        },

        generateSecondTable(worksheet, wasteData) {
            // Add 3 blank rows before Chapter 2
            worksheet.addRow([]);

            // Add title for Chapter 2
            const chapterTitleRow = worksheet.addRow(['CAPITOLUL 2: Stocarea provizorie, tratarea si transportul deseurilor']);
            chapterTitleRow.font = { bold: true };
            worksheet.mergeCells(`A${chapterTitleRow.number}:H${chapterTitleRow.number}`);
            worksheet.getCell(`A${chapterTitleRow.number}`).alignment = { horizontal: 'center', vertical: 'middle' };

            // Add headers
            worksheet.addRow([
                'Luna',
                'Stocare',
                '',
                '',
                'Tratare',
                '',
                'Transport',
                '',
            ]);
            const headerRow = worksheet.lastRow.number;
            worksheet.mergeCells(`B${headerRow}:D${headerRow}`); // Merge "Stocare" columns
            worksheet.mergeCells(`E${headerRow}:F${headerRow}`); // Merge "Tratare" columns
            worksheet.mergeCells(`G${headerRow}:H${headerRow}`); // Merge "Transport" columns
            worksheet.getRow(headerRow).font = { bold: true };

            // Add sub-headers
            worksheet.addRow([
                '', // Luna
                'Cantitate', 'Tip', 'Modul', // Stocare
                'Cantitate', 'Scopul', // Tratare
                'Mijlocul', 'Destinatia', // Transport
            ]);
            const subHeaderRow = worksheet.lastRow.number;
            worksheet.getRow(subHeaderRow).font = { bold: true };

            // Style the headers and sub-headers
            [headerRow, subHeaderRow].forEach((rowNumber) => {
                worksheet.getRow(rowNumber).eachCell({ includeEmpty: true }, (cell) => {
                    cell.alignment = { horizontal: 'center', vertical: 'middle' };
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' },
                    };
                });
            });

            // Add data rows
            const months = [
                'Ianuarie',
                'Februarie',
                'Martie',
                'Aprilie',
                'Mai',
                'Iunie',
                'Iulie',
                'August',
                'Septembrie',
                'Octombrie',
                'Noiembrie',
                'Decembrie',
            ];

            months.forEach((month) => {
                const monthData = wasteData.filter((item) => item.month === month);

                const totalStocare = monthData.reduce((sum, item) => sum + item.outbound.Stocat.quantity, 0);
                const totalTratare = monthData.reduce((sum, item) => sum + item.outbound.Tratat.quantity, 0);
                const totalTransport = monthData.reduce((sum, item) => sum + item.outbound.Transportat.quantity, 0);

                const row = worksheet.addRow([
                    month,
                    totalStocare, 'RP', '', // Stocare columns
                    totalTratare, 'AS', // Tratare columns
                    'AS', 'Vr', // Transport columns
                ]);

                // Style each cell in the row
                row.eachCell({ includeEmpty: true }, (cell) => {
                    cell.alignment = { horizontal: 'center', vertical: 'middle' };
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' },
                    };
                });
            });

            // Add a total row
            const totalRow = worksheet.addRow([
                'Total',
                wasteData.reduce((sum, item) => sum + item.outbound.Stocat.quantity, 0), // Total Stocare
                '', '', // Empty cells for Stocare details
                wasteData.reduce((sum, item) => sum + item.outbound.Tratat.quantity, 0), // Total Tratare
                '', // Empty cell for Tratare details
                '', '', // Empty cells for Transport details
            ]);
            totalRow.font = { bold: true };
            totalRow.eachCell({ includeEmpty: true }, (cell) => {
                cell.alignment = { horizontal: 'center', vertical: 'middle' };
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });
        },

        generateFirstTable(worksheet, wasteData) {
            // Set wider column widths
            worksheet.columns = [
                { width: 25 }, // Month
                { width: 20 }, // Generate
                { width: 25 }, // Valorificata
                { width: 25 }, // Eliminata
                { width: 20 }, // Stoc
            ];

            // Add title for the first table
            worksheet.mergeCells('A1:E1');
            worksheet.getCell('A1').value = 'EVIDENTA GESTIUNII DESEURILOR (conform H.G. 856/2002)';
            worksheet.getCell('A1').font = { bold: true, size: 14 };
            worksheet.getCell('A1').alignment = { horizontal: 'center', vertical: 'middle' };

            // Add general information
            worksheet.getCell('A3').value = 'Administratia publica:';
            worksheet.getCell('A4').value = 'Anul:';
            worksheet.getCell('A5').value = 'Tipul de deseu:';
            worksheet.getCell('A6').value = 'Stare fizica:';
            worksheet.getCell('A7').value = 'Unitatea de masura:';

            const firstItem = wasteData[0];
            worksheet.getCell('B4').value = this.year;
            worksheet.getCell('B5').value = firstItem.name;
            worksheet.getCell('B6').value = 'Solida';
            worksheet.getCell('B7').value = firstItem.unit;

            // Add table headers
            worksheet.mergeCells('A9:A10'); // Merge cells for "Luna"
            worksheet.mergeCells('B9:B10'); // Merge cells for "Generate"
            worksheet.mergeCells('C9:D9'); // Merge cells for "Cantitate de deseuri"
            worksheet.mergeCells('E9:E10'); // Merge cells for "Stoc"

            worksheet.getCell('A9').value = 'Luna';
            worksheet.getCell('B9').value = 'Generate';
            worksheet.getCell('C9').value = 'Cantitate de deseuri';
            worksheet.getCell('C10').value = 'Valorificata';
            worksheet.getCell('D10').value = 'Eliminata final';
            worksheet.getCell('E9').value = 'Stoc';

            // Style headers
            const headerCells = ['A9', 'B9', 'C9', 'D9', 'E9', 'C10', 'D10'];
            headerCells.forEach((cell) => {
                worksheet.getCell(cell).font = { bold: true };
                worksheet.getCell(cell).alignment = { horizontal: 'center', vertical: 'middle' };
                worksheet.getCell(cell).border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });

            // Process wasteData to calculate monthly totals
            const months = [
                'Ianuarie',
                'Februarie',
                'Martie',
                'Aprilie',
                'Mai',
                'Iunie',
                'Iulie',
                'August',
                'Septembrie',
                'Octombrie',
                'Noiembrie',
                'Decembrie',
            ];

            const monthlyTotals = months.map((month) => {
                const monthData = wasteData.filter((item) => item.month === month);
                const generate = monthData.reduce((sum, item) => sum + item.quantity, 0);
                const valorificata = monthData.reduce((sum, item) => sum + item.outbound.Valorificat.quantity, 0);
                const eliminata = monthData.reduce((sum, item) => sum + item.outbound.Eliminat.quantity, 0);
                const stoc = generate - (valorificata + eliminata);
                return { month, generate, valorificata, eliminata, stoc };
            });

            // Add data rows
            monthlyTotals.forEach((data) => {
                const row = worksheet.addRow([
                    data.month,
                    data.generate,
                    data.valorificata,
                    data.eliminata,
                    data.stoc,
                ]);

                // Style cells
                row.eachCell({ includeEmpty: true }, (cell) => {
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' },
                    };
                    cell.alignment = { horizontal: 'center', vertical: 'middle' };
                });
            });

            // Add a total row
            const totalRow = worksheet.addRow(['TOTAL AN']);
            totalRow.font = { bold: true };

            totalRow.getCell(2).value = monthlyTotals.reduce((sum, row) => sum + row.generate, 0);
            totalRow.getCell(3).value = monthlyTotals.reduce((sum, row) => sum + row.valorificata, 0);
            totalRow.getCell(4).value = monthlyTotals.reduce((sum, row) => sum + row.eliminata, 0);
            totalRow.getCell(5).value = monthlyTotals.reduce((sum, row) => sum + row.stoc, 0);

            totalRow.eachCell({ includeEmpty: true }, (cell) => {
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' },
                };
            });
        },

        async downloadExcel() {
            const workbook = new ExcelJS.Workbook();

            // Filter the waste list by year and group by code
            const filteredData = this.filterWasteListByYearAndCode(this.wasteList, this.year);

            // Create a sheet for each waste code
            Object.keys(filteredData).forEach((code) => {
                const worksheet = workbook.addWorksheet(code);
                this.generateFirstTable(worksheet, filteredData[code]);
                this.generateSecondTable(worksheet, filteredData[code]);
                this.generateThirdTable(worksheet, filteredData[code]);
                this.generateFourthTable(worksheet, filteredData[code]);
            });

            // Save the workbook
            const buffer = await workbook.xlsx.writeBuffer();
            const blob = new Blob([buffer], {
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            });
            saveAs(blob, 'waste-management-report.xls');
        },
    },
};
</script>

<style scoped>
.excel-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: 50px;
}

.download-btn {
    padding: 10px 20px;
    font-size: 16px;
    background-color: #4caf50;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

.download-btn:hover {
    background-color: #45a049;
}
</style>