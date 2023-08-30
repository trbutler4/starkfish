
fn get_rank_index(sq: usize) -> usize {
    (sq / 8)
}

fn get_file_index(sq: usize) -> usize {
    (sq % 8)
}

#[test]
#[available_gas(9999999)]
fn test_get_rank_index() {
    // board layout (rank and file indexes)
    //  7   56	57	58	59	60	61	62	63
    //  6   48	49	50	51	52	53	54	55
    //  5   40	41	42	43	44	45	46	47
    //  4   32	33	34	35	36	37	38	39
    //  3   24	25	26	27	28	29	30	31
    //  2   16	17	18	19	20	21	22	23
    //  1   08	09	10	11	12	13	14	15
    //  0   00	01	02	03	04	05	06	07
    //      0   1   2   3   4   5   7   8
    assert(get_rank_index(0) == 0, 'a1');
    assert(get_rank_index(9) == 1, 'b2');
    assert(get_rank_index(35) == 4, 'd5');
    assert(get_rank_index(63) == 7, 'h8');
}

#[test]
#[available_gas(9999999)]
fn test_get_file_index() {
    // board layout 	
    //  8   56	57	58	59	60	61	62	63
    //  7   48	49	50	51	52	53	54	55
    //  6   40	41	42	43	44	45	46	47
    //  5   32	33	34	35	36	37	38	39
    //  4   24	25	26	27	28	29	30	31
    //  3   16	17	18	19	20	21	22	23
    //  2   08	09	10	11	12	13	14	15
    //  1   00	01	02	03	04	05	06	07
    //      a   b   c   d   e   f   g   h
    assert(get_file_index(0) == 0, 'a1');
    assert(get_file_index(9) == 1, 'b2');
    assert(get_file_index(35) == 3, 'd5');
    assert(get_file_index(63) == 7, 'h8');
}
