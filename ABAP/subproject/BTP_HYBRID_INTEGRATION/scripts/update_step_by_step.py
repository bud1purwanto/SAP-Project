import re

file_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add callout in Chapter 1 if not present
callout = """> [!TIP]
> **Bedah Arsitektur & Alur Data Mendalam:**  
> Untuk penjelasan teknis lengkap dari database fisik S/4HANA (`EKKO`/`EKPO`), CDS View `C_PurchaseOrderItemMoni`, OData Gateway, reverse tunnel Cloud Connector, hingga siklus 1 detik saat tombol "Go" ditekan di browser, silakan baca dokumen terpisah:  
> 📖 [END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md](./END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md)
"""

if "END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md" not in content:
    # Insert right before ## 2. Tahap 1
    content = content.replace("## 2. Tahap 1: Verifikasi & Persiapan S/4HANA On-Premise", callout + "\n---\n\n## 2. Tahap 1: Verifikasi & Persiapan S/4HANA On-Premise")

# 2. Add Section 8.7 before ## 9. Matriks Troubleshooting
sec_8_7 = """### 8.7 Kustomisasi Permanen Kolom PO & FilterBar via `annotation.xml`

Secara bawaan (*default out-of-the-box*) SAP, kolom `PurchaseOrder` dan `PurchaseOrderItem` tidak dimasukkan ke dalam `UI.LineItem` tabel awal (hanya menampilkan Material, Supplier, Qty, dan Amount). Selain itu di FilterBar, kolom pencarian Nomor PO belum tersedia.

#### A. Mengapa Tombol "+" di Page Editor / Page Map Membuka "Add Custom Column"?
Ketika developer mencoba menambahkan kolom melalui GUI visual *Page Editor* (Page Map) pada aplikasi **OData V2** (`MM_PUR_POITEMS_MONI_SRV`), tombol `+` pada seksi *Columns* sengaja didesain SAP untuk membuat *Custom Column Extension* (berbasis fragment XML dan JavaScript Controller). Untuk properti standar OData, Fiori Elements mengatur tampilannya melalui file **`webapp/annotations/annotation.xml`**.

#### B. Konfigurasi Permanen `annotation.xml`
Dengan menyisipkan anotasi `UI.SelectionFields` dan `UI.LineItem` di dalam `webapp/annotations/annotation.xml`, nomor Purchase Order dan Item secara permanen tampil di urutan paling depan tabel dan filter PO langsung tersedia di FilterBar:

```xml
<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
    <edmx:Reference Uri="https://sap.github.io/odata-vocabularies/vocabularies/Common.xml">
        <edmx:Include Namespace="com.sap.vocabularies.Common.v1" Alias="Common"/>
    </edmx:Reference>
    <edmx:Reference Uri="https://sap.github.io/odata-vocabularies/vocabularies/UI.xml">
        <edmx:Include Namespace="com.sap.vocabularies.UI.v1" Alias="UI"/>
    </edmx:Reference>
    <edmx:Reference Uri="https://sap.github.io/odata-vocabularies/vocabularies/Communication.xml">
        <edmx:Include Namespace="com.sap.vocabularies.Communication.v1" Alias="Communication"/>
    </edmx:Reference>
    <edmx:Reference Uri="/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata">
        <edmx:Include Namespace="MM_PUR_POITEMS_MONI_SRV" Alias="SAP"/>
    </edmx:Reference>
    <edmx:DataServices>
        <Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="local">
            <Annotations Target="SAP.C_PurchaseOrderItemMoniResult">
                <!-- 1. FILTER BAR PERMANEN (UI.SelectionFields) -->
                <Annotation Term="UI.SelectionFields">
                    <Collection>
                        <PropertyPath>PurchaseOrder</PropertyPath>
                        <PropertyPath>Supplier</PropertyPath>
                        <PropertyPath>Material</PropertyPath>
                        <PropertyPath>Plant</PropertyPath>
                    </Collection>
                </Annotation>

                <!-- 2. KOLOM TABEL PERMANEN (UI.LineItem) -->
                <Annotation Term="UI.LineItem">
                    <Collection>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="PurchaseOrder"/>
                            <PropertyValue Property="Label" String="Purchase Order"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="PurchaseOrderItem"/>
                            <PropertyValue Property="Label" String="Item"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="Material"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="Supplier"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="ScheduleLineDeliveryDate"/>
                            <PropertyValue Property="Label" String="Next Delivery Date"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="ScheduleLineOpenQty"/>
                            <PropertyValue Property="Label" String="Next Delivery Qty"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="OrderQuantity"/>
                            <PropertyValue Property="Label" String="Order Qty"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="NetPriceAmount"/>
                            <PropertyValue Property="Label" String="Net Price"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                        <Record Type="UI.DataField">
                            <PropertyValue Property="Value" Path="NetAmount"/>
                            <PropertyValue Property="Label" String="Net Order Value"/>
                            <Annotation Term="UI.Importance" EnumMember="UI.ImportanceType/High"/>
                        </Record>
                    </Collection>
                </Annotation>
            </Annotations>
        </Schema>
    </edmx:DataServices>
</edmx:Edmx>
```

---

"""

if "8.7 Kustomisasi Permanen Kolom PO" not in content:
    content = content.replace("## 9. Matriks Troubleshooting & Solusi Lengkap", sec_8_7 + "## 9. Matriks Troubleshooting & Solusi Lengkap")

# 3. Add Troubleshooting row for Add Custom Column
tb_row = "| Tombol \"+\" di Page Editor membuka \"Add Custom Column\" | Di Fiori Elements OData V2, tombol \"+\" khusus ekstensi fragment. Kustomisasi kolom OData standar dilakukan permanen via `webapp/annotations/annotation.xml`. |\n"
if "Tombol \"+\" di Page Editor membuka \"Add Custom Column\"" not in content:
    content = re.sub(r'(\| Penanganan port preview mismatch.*?\n)', r'\1' + tb_row, content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated STEP_BY_STEP_IMPLEMENTATION_GUIDE.md successfully.")
