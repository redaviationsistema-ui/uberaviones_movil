import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class RoleWorkspaceItem {
  final String label;
  final String shortLabel;
  final String groupLabel;
  final String description;
  final IconData icon;
  final Widget screen;

  const RoleWorkspaceItem({
    required this.label,
    required this.shortLabel,
    required this.groupLabel,
    required this.description,
    required this.icon,
    required this.screen,
  });
}

class RoleWorkspaceShell extends StatefulWidget {
  const RoleWorkspaceShell({
    super.key,
    required this.branchLabel,
    required this.roleLabel,
    required this.title,
    required this.insightTitle,
    required this.insightDescription,
    required this.items,
    this.initialIndex = 0,
  });

  final String branchLabel;
  final String roleLabel;
  final String title;
  final String insightTitle;
  final String insightDescription;
  final List<RoleWorkspaceItem> items;
  final int initialIndex;

  @override
  State<RoleWorkspaceShell> createState() => _RoleWorkspaceShellState();
}

class _RoleWorkspaceShellState extends State<RoleWorkspaceShell> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width >= 1040;
    final currentItem = widget.items[_selectedIndex];
    final userEmail = auth.demoUser?.email ?? auth.user?.email ?? 'sin correo';
    final groupedItems = _groupItems(widget.items);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3EEE4),
      drawer:
          isWide
              ? null
              : _WorkspaceDrawer(
                branchLabel: widget.branchLabel,
                roleLabel: widget.roleLabel,
                title: widget.title,
                insightTitle: widget.insightTitle,
                insightDescription: widget.insightDescription,
                userEmail: userEmail,
                groupedItems: groupedItems,
                selectedIndex: _selectedIndex,
                onSelect: _selectIndex,
                onLogout: auth.signOut,
              ),
      body: SafeArea(
        child:
            isWide
                ? Row(
                  children: [
                    _WorkspaceSidebar(
                      branchLabel: widget.branchLabel,
                      roleLabel: widget.roleLabel,
                      title: widget.title,
                      insightTitle: widget.insightTitle,
                      insightDescription: widget.insightDescription,
                      userEmail: userEmail,
                      groupedItems: groupedItems,
                      selectedIndex: _selectedIndex,
                      onSelect: _selectIndex,
                      onLogout: auth.signOut,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _WorkspaceTopStrip(item: currentItem),
                          Expanded(child: currentItem.screen),
                        ],
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    _MobileWorkspaceHeader(
                      title: widget.title,
                      roleLabel: widget.roleLabel,
                      item: currentItem,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(child: currentItem.screen),
                  ],
                ),
      ),
    );
  }

  Map<String, List<_IndexedWorkspaceItem>> _groupItems(List<RoleWorkspaceItem> items) {
    final grouped = <String, List<_IndexedWorkspaceItem>>{};
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      grouped.putIfAbsent(item.groupLabel, () => []);
      grouped[item.groupLabel]!.add(_IndexedWorkspaceItem(index: index, item: item));
    }
    return grouped;
  }

  void _selectIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

class _IndexedWorkspaceItem {
  const _IndexedWorkspaceItem({required this.index, required this.item});

  final int index;
  final RoleWorkspaceItem item;
}

class _WorkspaceSidebar extends StatelessWidget {
  const _WorkspaceSidebar({
    required this.branchLabel,
    required this.roleLabel,
    required this.title,
    required this.insightTitle,
    required this.insightDescription,
    required this.userEmail,
    required this.groupedItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final String branchLabel;
  final String roleLabel;
  final String title;
  final String insightTitle;
  final String insightDescription;
  final String userEmail;
  final Map<String, List<_IndexedWorkspaceItem>> groupedItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF4EFE5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WorkspaceIdentityCard(
            branchLabel: branchLabel,
            roleLabel: roleLabel,
            title: title,
            userEmail: userEmail,
          ),
          const SizedBox(height: 16),
          _WorkspaceInsightCard(
            title: insightTitle,
            description: insightDescription,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE6DACA)),
              ),
              child: ListView(
                children:
                    groupedItems.entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _WorkspaceGroup(
                              label: entry.key,
                              items: entry.value,
                              selectedIndex: selectedIndex,
                              onSelect: onSelect,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _WorkspaceConciergeCard(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Salir de cuenta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8A4C40),
                backgroundColor: const Color(0xFFF9EEEA),
                side: const BorderSide(color: Color(0xFFF0D9D2)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceDrawer extends StatelessWidget {
  const _WorkspaceDrawer({
    required this.branchLabel,
    required this.roleLabel,
    required this.title,
    required this.insightTitle,
    required this.insightDescription,
    required this.userEmail,
    required this.groupedItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final String branchLabel;
  final String roleLabel;
  final String title;
  final String insightTitle;
  final String insightDescription;
  final String userEmail;
  final Map<String, List<_IndexedWorkspaceItem>> groupedItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF4EFE5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _WorkspaceIdentityCard(
                branchLabel: branchLabel,
                roleLabel: roleLabel,
                title: title,
                userEmail: userEmail,
              ),
              const SizedBox(height: 14),
              _WorkspaceInsightCard(
                title: insightTitle,
                description: insightDescription,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE6DACA)),
                  ),
                  child: ListView(
                    children:
                        groupedItems.entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _WorkspaceGroup(
                                  label: entry.key,
                                  items: entry.value,
                                  selectedIndex: selectedIndex,
                                  onSelect: onSelect,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _WorkspaceConciergeCard(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Salir de cuenta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8A4C40),
                    backgroundColor: const Color(0xFFF9EEEA),
                    side: const BorderSide(color: Color(0xFFF0D9D2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceIdentityCard extends StatelessWidget {
  const _WorkspaceIdentityCard({
    required this.branchLabel,
    required this.roleLabel,
    required this.title,
    required this.userEmail,
  });

  final String branchLabel;
  final String roleLabel;
  final String title;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCF6), Color(0xFFF5ECDD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE6DACA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFE0B86E), Color(0xFFF2D39C)],
              ),
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: Color(0xFF10253A),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'SKY GROUP ELITE',
            style: const TextStyle(
              color: Color(0xFFB07A1B),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roleLabel,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Priority access • concierge privado',
            style: const TextStyle(
              color: Color(0xFF6C6355),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            userEmail,
            style: const TextStyle(
              color: Color(0xFF8A7E6B),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceInsightCard extends StatelessWidget {
  const _WorkspaceInsightCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECDD),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Member note',
              style: TextStyle(
                color: Color(0xFFB07A1B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF6C6355),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceGroup extends StatelessWidget {
  const _WorkspaceGroup({
    required this.label,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final String label;
  final List<_IndexedWorkspaceItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB07A1B),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _WorkspaceNavTile(
              label: entry.item.label,
              description: entry.item.description,
              icon: entry.item.icon,
              isSelected: entry.index == selectedIndex,
              onTap: () => onSelect(entry.index),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceNavTile extends StatelessWidget {
  const _WorkspaceNavTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? const Color(0xFF111111) : const Color(0xFF2B261F);
    final secondary =
        isSelected
            ? const Color(0xFF6C6355)
            : const Color(0xFF8A7E6B);
    final background =
        isSelected ? const Color(0xFFF5ECDD) : const Color(0xFFFFFCF7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE4D3B6) : const Color(0xFFECE1D1),
          ),
          boxShadow:
              isSelected
                  ? const [
                    BoxShadow(
                      color: Color(0x10B07A1B),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: 3,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFB07A1B),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkspaceConciergeCard extends StatelessWidget {
  const _WorkspaceConciergeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6DACA)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.support_agent_rounded,
            color: Color(0xFFB07A1B),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Concierge',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Atencion 24/7 para reservas y cambios',
                  style: TextStyle(
                    color: Color(0xFF6C6355),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceTopStrip extends StatelessWidget {
  const _WorkspaceTopStrip({required this.item});

  final RoleWorkspaceItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xF20A1621),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.groupLabel,
              style: const TextStyle(
                color: Color(0xFFE0B86E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _HeaderIcon(icon: Icons.notifications_none_rounded),
          const SizedBox(width: 8),
          _HeaderIcon(icon: Icons.workspace_premium_rounded),
          const SizedBox(width: 8),
          const _HeaderAvatar(label: 'PC'),
        ],
      ),
    );
  }
}

class _MobileWorkspaceHeader extends StatelessWidget {
  const _MobileWorkspaceHeader({
    required this.title,
    required this.roleLabel,
    required this.item,
    required this.onMenuTap,
  });

  final String title;
  final String roleLabel;
  final RoleWorkspaceItem item;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sky Group',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Private Client',
                    style: TextStyle(
                      color: Color(0xFF7A6D59),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0E6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2D5C1)),
            ),
            child: const Text(
              'Elite',
              style: TextStyle(
                color: Color(0xFFB07A1B),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0E6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 16,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onMenuTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFFE0B86E)),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0B86E), Color(0xFFF2D39C)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF10253A),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
