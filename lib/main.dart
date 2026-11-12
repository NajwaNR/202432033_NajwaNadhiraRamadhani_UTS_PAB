import 'package:flutter/material.dart';

void main() => runApp(const KeuanganApp());

// ===================== MODEL =====================
class Kategori {
  final String nama;
  final IconData ikon;
  final Color warna;
  final String gambar;
  const Kategori(this.nama, this.ikon, this.warna, this.gambar);
}

class Transaksi {
  final String judul;
  final int nominal;
  final String kategori;
  final DateTime tanggal;
  final String catatan;
  final bool pemasukan;

  Transaksi({
    required this.judul,
    required this.nominal,
    required this.kategori,
    required this.tanggal,
    required this.catatan,
    required this.pemasukan,
  });
}

class Budget {
  final int harian;
  final int bulanan;
  const Budget(this.harian, this.bulanan);
}

const List<Kategori> kategoriKeluar = [
  Kategori('Makan', Icons.restaurant, Colors.orange, 'assets/images/makan.png'),
  Kategori('Transportasi', Icons.directions_bus, Colors.blue, 'assets/images/transportasi.png'),
  Kategori('Kuliah', Icons.school, Colors.purple, 'assets/images/kuliah.png'),
  Kategori('Hiburan', Icons.sports_esports, Colors.pink, 'assets/images/hiburan.png'),
  Kategori('Belanja', Icons.shopping_bag, Colors.teal, 'assets/images/belanja.png'),
  Kategori('Lainnya', Icons.more_horiz, Colors.grey, 'assets/images/lainnya.png'),
];

const Kategori kategoriMasuk =
    Kategori('Pemasukan', Icons.savings, Colors.green, 'assets/images/pemasukan.png');

Kategori cariKategori(String nama) {
  if (nama == kategoriMasuk.nama) return kategoriMasuk;
  return kategoriKeluar.firstWhere((k) => k.nama == nama, orElse: () => kategoriKeluar.last);
}

Widget gambarKategori(Kategori k, {required double width, required double height}) {
  final cadangan = Container(
    width: width,
    height: height,
    color: k.warna.withAlpha(40),
    child: Icon(k.ikon, color: k.warna),
  );
  if (k.gambar.startsWith('http')) {
    return Image.network(
      k.gambar,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => cadangan,
    );
  }
  return Image.asset(
    k.gambar,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stack) => cadangan,
  );
}

// ===================== HELPER =====================
String rupiah(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}Rp $b';
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];
const List<String> namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

String formatTanggal(DateTime d) => '${d.day} ${namaBulan[d.month - 1]} ${d.year}';

const List<String> namaHariPenuh = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

String labelHari(DateTime d) {
  final now = DateTime.now();
  if (sameDay(d, now)) return 'Hari ini';
  if (sameDay(d, now.subtract(const Duration(days: 1)))) return 'Kemarin';
  return namaHariPenuh[d.weekday - 1];
}

Color warnaStatus(double rasio) {
  if (rasio < 0.7) return Colors.green;
  if (rasio < 1) return Colors.orange;
  return Colors.red;
}

String teksStatus(double rasio) {
  if (rasio < 0.7) return 'Aman';
  if (rasio < 1) return 'Hampir habis';
  return 'Melebihi batas';
}

// ===================== APP =====================
class KeuanganApp extends StatelessWidget {
  const KeuanganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ===================== HALAMAN UTAMA =====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  Budget _budget = const Budget(50000, 1000000);
  String _filter = 'Semua';
  late final List<Transaksi> _transaksi;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() => setState(() {}));

    final now = DateTime.now();
    DateTime hariLalu(int n) => DateTime(now.year, now.month, now.day).subtract(Duration(days: n));
    _transaksi = [
      Transaksi(judul: 'Uang saku bulanan', nominal: 1500000, kategori: 'Pemasukan', tanggal: hariLalu(6), catatan: 'Kiriman orang tua', pemasukan: true),
      Transaksi(judul: 'Nasi goreng', nominal: 18000, kategori: 'Makan', tanggal: hariLalu(0), catatan: 'Makan siang kantin', pemasukan: false),
      Transaksi(judul: 'Ojek online', nominal: 22000, kategori: 'Transportasi', tanggal: hariLalu(0), catatan: 'Berangkat kuliah', pemasukan: false),
      Transaksi(judul: 'Fotokopi modul', nominal: 12000, kategori: 'Kuliah', tanggal: hariLalu(1), catatan: 'Modul praktikum', pemasukan: false),
      Transaksi(judul: 'Nonton bioskop', nominal: 45000, kategori: 'Hiburan', tanggal: hariLalu(2), catatan: 'Bareng teman', pemasukan: false),
      Transaksi(judul: 'Beli alat tulis', nominal: 30000, kategori: 'Belanja', tanggal: hariLalu(3), catatan: 'Pulpen dan buku', pemasukan: false),
      Transaksi(judul: 'Makan malam', nominal: 25000, kategori: 'Makan', tanggal: hariLalu(3), catatan: 'Warteg', pemasukan: false),
      Transaksi(judul: 'Kereta commuter', nominal: 14000, kategori: 'Transportasi', tanggal: hariLalu(4), catatan: 'PP kampus', pemasukan: false),
      Transaksi(judul: 'Kopi', nominal: 20000, kategori: 'Makan', tanggal: hariLalu(5), catatan: 'Ngerjain tugas', pemasukan: false),
      Transaksi(judul: 'Top up game', nominal: 50000, kategori: 'Hiburan', tanggal: hariLalu(6), catatan: 'Akhir pekan', pemasukan: false),
    ];
    _urutkan();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _urutkan() => _transaksi.sort((a, b) => b.tanggal.compareTo(a.tanggal));

  // ---------- perhitungan ----------
  int get _totalMasuk => _transaksi.where((t) => t.pemasukan).fold(0, (s, t) => s + t.nominal);
  int get _totalKeluar => _transaksi.where((t) => !t.pemasukan).fold(0, (s, t) => s + t.nominal);
  int get _saldo => _totalMasuk - _totalKeluar;

  int _keluarPadaHari(DateTime d) =>
      _transaksi.where((t) => !t.pemasukan && sameDay(t.tanggal, d)).fold(0, (s, t) => s + t.nominal);

  int get _keluarHariIni => _keluarPadaHari(DateTime.now());

  int get _keluarBulanIni {
    final n = DateTime.now();
    return _transaksi
        .where((t) => !t.pemasukan && t.tanggal.year == n.year && t.tanggal.month == n.month)
        .fold(0, (s, t) => s + t.nominal);
  }

  int _totalKategori(String nama) =>
      _transaksi.where((t) => t.kategori == nama).fold(0, (s, t) => s + t.nominal);

  int _jumlahKategori(String nama) => _transaksi.where((t) => t.kategori == nama).length;

  // ---------- navigasi ----------
  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _tambahTransaksi() async {
    final hasil = await Navigator.push<Transaksi>(
      context,
      MaterialPageRoute(builder: (_) => const FormTransaksiPage()),
    );
    if (!mounted) return;
    if (hasil != null) {
      setState(() {
        _transaksi.add(hasil);
        _urutkan();
      });
      _pesan('Transaksi berhasil ditambahkan');
    }
  }

  Future<void> _aturBudget() async {
    final hasil = await Navigator.push<Budget>(
      context,
      MaterialPageRoute(builder: (_) => BudgetFormPage(budget: _budget)),
    );
    if (!mounted) return;
    if (hasil != null) {
      setState(() => _budget = hasil);
      _pesan('Budget berhasil disimpan');
    }
  }

  Future<void> _bukaDetail(Transaksi t) async {
    final aksi = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => DetailTransaksiPage(transaksi: t)),
    );
    if (!mounted) return;
    if (aksi == 'hapus') {
      setState(() => _transaksi.remove(t));
      _pesan('Transaksi dihapus');
    }
  }

  void _bukaKategori(Kategori k) {
    final daftar = _transaksi.where((t) => t.kategori == k.nama).toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransaksiKategoriPage(kategori: k, daftar: daftar)),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        bottom: TabBar(
          controller: _tab,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transaksi'),
            Tab(icon: Icon(Icons.category), text: 'Kategori'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Budget'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _tabDashboard(),
          _tabTransaksi(),
          _tabKategori(),
          _tabBudget(),
        ],
      ),
      floatingActionButton: _tab.index == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: _tab.index == 3 ? _aturBudget : _tambahTransaksi,
              icon: Icon(_tab.index == 3 ? Icons.tune : Icons.add),
              label: Text(_tab.index == 3 ? 'Atur Budget' : 'Tambah Transaksi'),
            ),
    );
  }

  // ===================== TAB 1: DASHBOARD =====================
  Widget _tabDashboard() {
    final rasioHari = _budget.harian == 0 ? 0.0 : _keluarHariIni / _budget.harian;
    final rasioBulan = _budget.bulanan == 0 ? 0.0 : _keluarBulanIni / _budget.bulanan;

    // data grafik 7 hari terakhir
    final now = DateTime.now();
    final hari7 = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final nilai7 = hari7.map(_keluarPadaHari).toList();
    int maks = 1;
    for (final v in nilai7) {
      if (v > maks) maks = v;
    }

    final totalKeluar = _totalKeluar == 0 ? 1 : _totalKeluar;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Kartu saldo + Image.asset
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (context, error, stack) => const Icon(Icons.account_balance_wallet, size: 56),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Saat Ini'),
                      Text(
                        rupiah(_saldo),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _saldo < 0 ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _kartuRingkas('Pemasukan', _totalMasuk, Icons.arrow_downward, Colors.green)),
            Expanded(child: _kartuRingkas('Pengeluaran', _totalKeluar, Icons.arrow_upward, Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        _judul('Performa Budget'),
        _kartuBudget('Hari ini', _keluarHariIni, _budget.harian, rasioHari),
        _kartuBudget('Bulan ini', _keluarBulanIni, _budget.bulanan, rasioBulan),
        const SizedBox(height: 8),
        _judul('Pengeluaran 7 Hari Terakhir'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final tinggi = (nilai7[i] / maks) * 100;
                  final lewat = _budget.harian > 0 && nilai7[i] > _budget.harian;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        nilai7[i] == 0 ? '' : '${(nilai7[i] / 1000).round()}k',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 24,
                        height: tinggi < 2 ? 2 : tinggi,
                        decoration: BoxDecoration(
                          color: lewat ? Colors.red : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(namaHari[hari7[i].weekday - 1], style: const TextStyle(fontSize: 11)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Batang merah = melebihi budget harian', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ),
        const SizedBox(height: 8),
        _judul('Pengeluaran per Kategori'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: kategoriKeluar.map((k) {
                final total = _totalKategori(k.nama);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(k.ikon, color: k.warna),
                      const SizedBox(width: 8),
                      SizedBox(width: 90, child: Text(k.nama, style: const TextStyle(fontSize: 13))),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: total / totalKeluar,
                          color: k.warna,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(rupiah(total), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _judul('Transaksi Terbaru'),
        ..._transaksi.take(3).map(_itemTransaksi),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        child: Text(teks, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _kartuRingkas(String label, int nilai, IconData ikon, Color warna) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: warna.withAlpha(40), child: Icon(ikon, color: warna)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12)),
                  Text(rupiah(nilai), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBudget(String judul, int terpakai, int batas, double rasio) {
    final warna = warnaStatus(rasio);
    final sisa = batas - terpakai;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(judul, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(teksStatus(rasio), style: TextStyle(color: warna, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: rasio > 1 ? 1 : rasio,
              color: warna,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text('${rupiah(terpakai)} dari ${rupiah(batas)}'),
            Text(
              sisa >= 0 ? 'Sisa ${rupiah(sisa)}' : 'Lebih ${rupiah(-sisa)} dari batas',
              style: TextStyle(color: warna, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTransaksi(Transaksi t) {
    final k = cariKategori(t.kategori);
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: k.warna.withAlpha(40), child: Icon(k.ikon, color: k.warna)),
        title: Text(t.judul),
        subtitle: Text('${t.kategori} • ${formatTanggal(t.tanggal)}'),
        trailing: Text(
          '${t.pemasukan ? '+' : '-'}${rupiah(t.nominal)}',
          style: TextStyle(color: t.pemasukan ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
        ),
        onTap: () => _bukaDetail(t),
      ),
    );
  }

  // ===================== TAB 2: TRANSAKSI =====================
  Widget _tabTransaksi() {
    final daftar = _transaksi.where((t) {
      if (_filter == 'Pemasukan') return t.pemasukan;
      if (_filter == 'Pengeluaran') return !t.pemasukan;
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: ['Semua', 'Pemasukan', 'Pengeluaran'].map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: Builder(builder: (context) {
            if (daftar.isEmpty) {
              return const Center(child: Text('Belum ada transaksi'));
            }

            final List<Object> items = [];
            DateTime? terakhir;
            for (final t in daftar) {
              if (terakhir == null || !sameDay(terakhir, t.tanggal)) {
                items.add(t.tanggal);
                terakhir = t.tanggal;
              }
              items.add(t);
            }

            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: items.length,
              separatorBuilder: (context, index) {
                final antarTransaksi = items[index] is Transaksi &&
                    index + 1 < items.length &&
                    items[index + 1] is Transaksi;
                return antarTransaksi ? const Divider(height: 1) : const SizedBox.shrink();
              },
              itemBuilder: (context, index) {
                final item = items[index];

                if (item is DateTime) {
                  final keluar = _keluarPadaHari(item);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Row(
                      children: [
                        Text(
                          '${item.day} ${namaBulan[item.month - 1]}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(labelHari(item), style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        if (keluar > 0)
                          Text(
                            'Keluar ${rupiah(keluar)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _budget.harian > 0 && keluar > _budget.harian
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                final t = item as Transaksi;
                final k = cariKategori(t.kategori);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: k.warna.withAlpha(40),
                    child: Icon(k.ikon, color: k.warna),
                  ),
                  title: Text(t.judul),
                  subtitle: Text(t.kategori),
                  trailing: Text(
                    '${t.pemasukan ? '+' : '-'}${rupiah(t.nominal)}',
                    style: TextStyle(
                      color: t.pemasukan ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _bukaDetail(t),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ===================== TAB 3: KATEGORI =====================
  Widget _tabKategori() {
    final semua = [...kategoriKeluar, kategoriMasuk];
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: semua.length,
      itemBuilder: (context, index) {
        final k = semua[index];
        return Card(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: gambarKategori(k, width: 52, height: 52),
            ),
            title: Text(k.nama),
            subtitle: Text('${_jumlahKategori(k.nama)} transaksi'),
            trailing: Text(rupiah(_totalKategori(k.nama)), style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => _bukaKategori(k),
          ),
        );
      },
    );
  }

  // ===================== TAB 4: BUDGET =====================
  Widget _tabBudget() {
    final now = DateTime.now();
    final akhirBulan = DateTime(now.year, now.month + 1, 0).day;
    final sisaHari = akhirBulan - now.day + 1;
    final sisaBulan = _budget.bulanan - _keluarBulanIni;
    final saran = sisaBulan > 0 ? sisaBulan ~/ sisaHari : 0;
    final rasioHari = _budget.harian == 0 ? 0.0 : _keluarHariIni / _budget.harian;
    final rasioBulan = _budget.bulanan == 0 ? 0.0 : _keluarBulanIni / _budget.bulanan;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengaturan Budget Saat Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Batas harian : ${rupiah(_budget.harian)}'),
                Text('Batas bulanan: ${rupiah(_budget.bulanan)}'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _aturBudget,
                    icon: const Icon(Icons.tune),
                    label: const Text('Ubah Budget'),
                  ),
                ),
              ],
            ),
          ),
        ),
        _kartuBudget('Budget harian (hari ini)', _keluarHariIni, _budget.harian, rasioHari),
        _kartuBudget('Budget bulanan', _keluarBulanIni, _budget.bulanan, rasioBulan),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saran Belanja Harian', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Sisa $sisaHari hari di bulan ini.'),
                Text(
                  sisaBulan > 0
                      ? 'Agar budget bulanan cukup, batasi belanja maksimal ${rupiah(saran)} per hari.'
                      : 'Budget bulanan sudah habis. Usahakan tidak ada pengeluaran tambahan.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ===================== DETAIL TRANSAKSI =====================
class DetailTransaksiPage extends StatelessWidget {
  final Transaksi transaksi;
  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final k = cariKategori(transaksi.kategori);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            gambarKategori(k, width: double.infinity, height: 200),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaksi.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${transaksi.pemasukan ? '+' : '-'}${rupiah(transaksi.nominal)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: transaksi.pemasukan ? Colors.green : Colors.red,
                    ),
                  ),
                  const Divider(height: 32),
                  _baris('Tipe', transaksi.pemasukan ? 'Pemasukan' : 'Pengeluaran'),
                  _baris('Kategori', transaksi.kategori),
                  _baris('Tanggal', formatTanggal(transaksi.tanggal)),
                  _baris('Catatan', transaksi.catatan.isEmpty ? '-' : transaksi.catatan),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, 'hapus'),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus Transaksi'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(': '),
          Expanded(child: Text(nilai, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

// ===================== TRANSAKSI PER KATEGORI =====================
class TransaksiKategoriPage extends StatelessWidget {
  final Kategori kategori;
  final List<Transaksi> daftar;
  const TransaksiKategoriPage({super.key, required this.kategori, required this.daftar});

  @override
  Widget build(BuildContext context) {
    final total = daftar.fold(0, (s, t) => s + t.nominal);
    return Scaffold(
      appBar: AppBar(title: Text('Kategori ${kategori.nama}')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: kategori.warna.withAlpha(40),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(kategori.ikon, size: 40, color: kategori.warna),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total ${kategori.nama}'),
                    Text(rupiah(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: daftar.isEmpty
                ? const Center(child: Text('Belum ada transaksi di kategori ini'))
                : ListView.builder(
                    itemCount: daftar.length,
                    itemBuilder: (context, index) {
                      final t = daftar[index];
                      return ListTile(
                        title: Text(t.judul),
                        subtitle: Text(formatTanggal(t.tanggal)),
                        trailing: Text(rupiah(t.nominal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ===================== FORM TAMBAH TRANSAKSI =====================
class FormTransaksiPage extends StatefulWidget {
  const FormTransaksiPage({super.key});

  @override
  State<FormTransaksiPage> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends State<FormTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  bool _pemasukan = false;
  String _kategori = kategoriKeluar.first.nama;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _nominalCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      Navigator.pop(
        context,
        Transaksi(
          judul: _judulCtrl.text.trim(),
          nominal: int.parse(_nominalCtrl.text.trim()),
          kategori: _pemasukan ? kategoriMasuk.nama : _kategori,
          tanggal: DateTime(now.year, now.month, now.day),
          catatan: _catatanCtrl.text.trim(),
          pemasukan: _pemasukan,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Pengeluaran'),
                    selected: !_pemasukan,
                    onSelected: (_) => setState(() => _pemasukan = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Pemasukan'),
                    selected: _pemasukan,
                    onSelected: (_) => setState(() => _pemasukan = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulCtrl,
                decoration: const InputDecoration(labelText: 'Judul transaksi', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nominalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
                  final angka = int.tryParse(v.trim());
                  if (angka == null || angka <= 0) return 'Masukkan angka lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_pemasukan) ...[
                const Text('Kategori'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: kategoriKeluar.map((k) {
                    return ChoiceChip(
                      avatar: Icon(k.ikon, size: 18, color: k.warna),
                      label: Text(k.nama),
                      selected: _kategori == k.nama,
                      onSelected: (_) => setState(() => _kategori = k.nama),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Text('Tanggal otomatis: ${formatTanggal(DateTime.now())}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== FORM ATUR BUDGET =====================
class BudgetFormPage extends StatefulWidget {
  final Budget budget;
  const BudgetFormPage({super.key, required this.budget});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _harianCtrl;
  late final TextEditingController _bulananCtrl;

  @override
  void initState() {
    super.initState();
    _harianCtrl = TextEditingController(text: widget.budget.harian.toString());
    _bulananCtrl = TextEditingController(text: widget.budget.bulanan.toString());
  }

  @override
  void dispose() {
    _harianCtrl.dispose();
    _bulananCtrl.dispose();
    super.dispose();
  }

  String? _cek(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final angka = int.tryParse(v.trim());
    if (angka == null || angka <= 0) return 'Masukkan angka lebih dari 0';
    return null;
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Budget(int.parse(_harianCtrl.text.trim()), int.parse(_bulananCtrl.text.trim())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atur Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _harianCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Batas pengeluaran harian (Rp)', border: OutlineInputBorder()),
                validator: _cek,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bulananCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Batas pengeluaran bulanan (Rp)', border: OutlineInputBorder()),
                validator: _cek,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _simpan, child: const Text('Simpan Budget')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}