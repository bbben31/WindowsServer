# Environment profiles

The learner runs every role in this curriculum, including the roles that an instructor or hosted training platform originally prepared. The adaptation removes the classroom dependency; it does not reduce the enterprise topology to one server.

Choose one profile before starting a procedure and record it in private lab notes. Do not combine addresses from different profiles inside the same Windows installation or snapshot lineage.

## Profile 1: Core learner foundation

Use this profile for the staged foundation and introductory administration work.

| Source label | VMware network | Address space | Purpose |
| --- | --- | --- | --- |
| Management / AD | `VMnet10` | `10.10.10.0/24` | AD DS, DNS, management |
| Server workload | `VMnet11` | `10.10.20.0/24` | Member servers and application traffic |
| Client | `VMnet12` | `10.10.30.0/24` | Windows clients |
| Outbound | `VMnet8` | VMware-assigned | Temporary NAT access |

The forest is `ad.lab.test`. `VN1-SRV1` is the first DC/DNS server at `10.10.10.10`; `VN1-SRV5` is the optional second DC/DNS server at `10.10.10.11`.

## Profile 2: Enterprise expansion

Use this profile when the selected manifest entry declares `networkProfile=enterprise`, including multi-site DNS, DHCP relay/failover, routing, clustering, PKI, federation, and migration procedures that use the original `VNet1`, `VNet2`, `VNet3`, or `10.1.x.x` segments. A `PM-*` guest name or `WIN-*` display alias alone does not select a subnet or hypervisor layer: some introductory core exercises retain those names on `10.10.x.x`. Follow the entry's explicit network profile and `vmTopology`, not a name-prefix guess.

Those values represent a complete enterprise exercise topology, not the three-network foundation. Preserve them within an isolated set of VMware custom networks. Create only the segments required by the current exercise, and power on only the required machines.

| Source network | VMware implementation | Address space |
| --- | --- | --- |
| `VNet1` | Dedicated host-only custom VMnet | `10.1.1.0/24` |
| `VNet2` | Dedicated host-only custom VMnet | `10.1.2.0/24` |
| `VNet3` | Dedicated host-only custom VMnet | `10.1.3.0/24` |
| Source networks `128`, `144`, `160`, `200`, `201` | One dedicated host-only custom VMnet per subnet, only when named by the exercise | `10.1.<network>.0/24` |

VMware network numbers are host-specific. Record a table mapping each source network to an unused custom VMnet before attaching guests. Disable VMware DHCP on every segment where Windows DHCP is part of the exercise. Do not bridge these networks to a home, school, or business LAN.

The enterprise expansion still uses `ad.lab.test` unless an exercise explicitly creates a second forest or child domain. Machine names such as `VN1-SRV*`, `VN2-SRV*`, `PM-SRV*`, `WIN-*`, `CL1`, and `CL2` are retained because they make the multi-site design and administrative boundaries visible.

## Profile 3: Isolated alternate forest

Multi-forest, migration, trust, and federation exercises may require an additional forest. Create the forest only for that exercise on dedicated enterprise-expansion segments. Preserve a source exercise's explicitly documented example namespace (including Microsoft's `ad.contoso.com`/`contoso.com` examples) only inside isolated lab DNS; never publish it or use a domain belonging to a real organization. For a new independent exercise, use a test namespace such as `corp2.lab.test`. Take a checkpoint before creating trusts or modifying forest-wide configuration.

## Translating platform actions

The source may manage an inner Hyper-V environment with VM-creation, virtual-switch-move, or memory-setting helpers. For the VMware learner environment, perform the equivalent operation in VMware Workstation:

1. Shut down the guest when the requested virtual hardware change requires it.
2. Record the current VMware network, memory, CPU, and disk configuration.
3. Attach the guest to the custom VMnet mapped to the source VNet, or change the requested memory/disk setting.
4. Start the guest and verify its adapter, address, routes, DNS servers, and domain connectivity.

When a procedure explicitly teaches Hyper-V, retain the Hyper-V steps and run them in a VM with nested virtualization enabled. Do not translate the technology being taught into VMware; translate only the outer classroom provisioning step.

## Self-learner responsibility boundary

Replace every classroom hand-off with one of these actions:

* build the named VM, network, identity, certificate, share, or role by completing the linked prerequisite;
* diagnose the failed verification using the documented checks and rollback to the named checkpoint;
* use an existing authorized Azure tenant and subscription with the exact least-privilege role required by the exercise;
* skip an optional exercise when licensing, quota, cost, hardware, or required permissions are unavailable.

Never invent credentials, copy source passwords, grant a broader role merely to bypass a permission error, or run an unavailable classroom helper as though it were included.
