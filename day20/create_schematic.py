import python_nbt.nbt as nbt

def generate_input_schematic(input_lines):
    ret = nbt.NBTTagCompound()
    ret['size'] = nbt.NBTTagList([
            nbt.NBTTagInt(len(input_lines[0])),
            nbt.NBTTagInt(1),
            nbt.NBTTagInt(len(input_lines))
        ],
        tag_type=nbt.NBTTagInt
    )

    ret['entities'] = nbt.NBTTagList([], tag_type=nbt.NBTTagEnd)

    black_wool = nbt.NBTTagCompound()
    black_wool['Name'] = nbt.NBTTagString("minecraft:black_wool")
    white_wool = nbt.NBTTagCompound()
    white_wool['Name'] = nbt.NBTTagString("minecraft:white_wool")

    ret['palette'] = nbt.NBTTagList([black_wool,white_wool],
        tag_type=nbt.NBTTagCompound
    )

    ret['blocks'] = nbt.NBTTagList(
        [],
        tag_type=nbt.NBTTagCompound
    )

    for j, line in enumerate(input_lines):
        for i, char in enumerate(line.strip()):
            block = nbt.NBTTagCompound()
            block['pos'] = nbt.NBTTagList([
                    nbt.NBTTagInt(i),
                    nbt.NBTTagInt(0),
                    nbt.NBTTagInt(j)
                ],
                tag_type=nbt.NBTTagInt
            )
            block['state'] = nbt.NBTTagInt(0 if char == '.' else 1)
            ret['blocks'] += [block]

    return ret

with open('input', 'r') as f:
    lines = list(f)
    nbt.write_to_nbt_file('./world/generated/minecraft/structures/input.nbt',
        generate_input_schematic([
            lines[0][i:i+64] for i in range(0, len(lines[0])-1, 64)
        ])
    )
    nbt.write_to_nbt_file('./world/generated/minecraft/structures/board.nbt', generate_input_schematic(lines[2:]))
