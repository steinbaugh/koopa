#!/usr/bin/env bash
# shellcheck disable=SC2039

koopa::conda_create_bioinfo_envs() {
    local all aligners chipseq data_mining file_formats methylation \
        quality_control rnaseq singlecell trimming variation workflows
    koopa::assert_is_installed conda
    all=0
    aligners=0
    chipseq=0
    data_mining=0
    file_formats=0
    methylation=0
    quality_control=0
    rnaseq=0
    singlecell=0
    trimming=0
    variation=0
    workflows=0
    # Set recommended defaults, if necessary.
    if [[ "$#" -eq 0 ]]
    then
        chipseq=1
        data_mining=1
        file_formats=1
        quality_control=1
        rnaseq=1
    fi
    while (("$#"))
    do
        case "$1" in
            --all)
                all=1
                shift 1
                ;;
            --aligners)
                aligners=1
                shift 1
                ;;
            --chipseq|--chip-seq)
                chipseq=1
                shift 1
                ;;
            --data-mining)
                data_mining=1
                shift 1
                ;;
            --file-formats)
                file_formats=1
                shift 1
                ;;
            --methylation)
                methylation=1
                shift 1
                ;;
            --qc|quality-control)
                quality_control=1
                shift 1
                ;;
            --rnaseq|--rna-seq)
                rnaseq=1
                shift 1
                ;;
            --singlecell|--single-cell|--scrnaseq)
                singlecell=1
                shift 1
                ;;
            --trimming)
                trimming=1
                shift 1
                ;;
            --variation)
                variation=1
                shift 1
                ;;
            --workflows)
                workflows=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ "$all" -eq 1 ]]
    then
        aligners=1
        chipseq=1
        data_mining=1
        file_formats=1
        methylation=1
        quality_control=1
        rnaseq=1
        singlecell=1
        trimming=1
        variation=1
        workflows=1
    fi
    koopa::h1 'Installing conda environments for bioinformatics.'
    if [[ "$file_formats" -eq 1 ]]
    then
        koopa::h2 'File formats'
        koopa::conda_create_env bamtools                                # 0.043G
        koopa::conda_create_env bcftools
        koopa::conda_create_env bedtools                                # 0.082G
        koopa::conda_create_env bioawk                                  # 0.027G
        koopa::conda_create_env gffutils                                # 0.222G
        koopa::conda_create_env htslib                                  # 0.082G
        koopa::conda_create_env sambamba
        koopa::conda_create_env samblaster                              # 0.039G
        koopa::conda_create_env samtools                                # 0.083G
        koopa::conda_create_env seqtk                                   # 0.027G
        if koopa::is_linux
        then
            koopa::conda_create_env biobambam                           # 0.065G
        fi
    fi
    if [[ "$data_mining" -eq 1 ]]
    then
        koopa::h2 'Data mining'
        koopa::conda_create_env entrez-direct                           # 0.154G
        koopa::conda_create_env sra-tools                               # 0.315G
    fi
    if [[ "$workflows" -eq 1 ]]
    then
        koopa::h2 'Workflows'
        koopa::conda_create_env cromwell                                # 0.724G
        koopa::conda_create_env fgbio                                   # 0.628G
        koopa::conda_create_env gatk4                                   # 0.658G
        koopa::conda_create_env jupyterlab                              # 0.410G
        koopa::conda_create_env nextflow                                # 0.518G
        koopa::conda_create_env snakemake                               # 0.788G
    fi
    if [[ "$quality_control" -eq 1 ]]
    then
        koopa::h2 'Quality control'
        koopa::conda_create_env fastqc                                  # 0.513G
        koopa::conda_create_env kraken                                  # 0.170G
        koopa::conda_create_env multiqc                                 # 1.100G
        koopa::conda_create_env picard                                  # 0.923G
        koopa::conda_create_env qualimap                                # 1.200G
    fi
    if [[ "$trimming" -eq 1 ]]
    then
        koopa::h2 'Trimming'
        koopa::conda_create_env atropos                                 # 0.152G
        koopa::conda_create_env trimmomatic                             # 0.095G
    fi
    if [[ "$aligners" -eq 1 ]]
    then
        koopa::h2 'Aligners'
        koopa::conda_create_env bowtie2                                 # 0.319G
        koopa::conda_create_env bwa                                     # 0.105G
        koopa::conda_create_env hisat2                                  # 0.260G
        koopa::conda_create_env minimap2                                # 0.045G
        koopa::conda_create_env novoalign                               # 0.092G
        koopa::conda_create_env rsem                                    # 0.744G
        koopa::conda_create_env star                                    # 0.009G
    fi
    if [[ "$variation" -eq 1 ]]
    then
        koopa::h2 'Variation'
        koopa::conda_create_env peddy                  # dna-seq        # 1.200G
        koopa::conda_create_env ericscript             # rna-seq        # 0.728G
        koopa::conda_create_env oncofuse               # rna-seq        # 0.507G
        koopa::conda_create_env pizzly                 # rna-seq        # 0.293G
        koopa::conda_create_env squid                  # rna-seq        # 0.041G
        koopa::conda_create_env star-fusion            # rna-seq        # 1.600G
        koopa::conda_create_env vardict                # rna-seq        # 0.396G
        if koopa::is_linux
        then
            koopa::conda_create_env arriba             # rna-seq        # 0.987G
        fi
    fi
    if [[ "$rnaseq" -eq 1 ]]
    then
        koopa::h2 'RNA-seq'
        # > koopa::conda_create_env r-bcbiornaseq                       # 2.200G
        # > koopa::conda_create_env r-deseqanalysis                     # 0.437G
        koopa::conda_create_env kallisto                                # 0.054G
        koopa::conda_create_env rapmap                                  # 0.088G
        koopa::conda_create_env salmon                                  # 0.192G
        koopa::conda_create_env star                                    # 0.009G
    fi
    if [[ "$chipseq" -eq 1 ]]
    then
        koopa::h2 'ChIP-seq'
        koopa::conda_create_env bowtie2                                 # 0.319G
        koopa::conda_create_env chromhmm                                # 0.428G
        koopa::conda_create_env deeptools                               # 1.200G
        koopa::conda_create_env genrich                                 # 0.000G
        koopa::conda_create_env homer                                   # 0.263G
        koopa::conda_create_env macs2                                   # 0.748G
        koopa::conda_create_env sicer2                                  # 0.748G
    fi
    if [[ "$singlecell" -eq 1 ]]
    then
        koopa::h2 'Single-cell RNA-seq'
        # > koopa::conda_create_env r-bcbiosinglecell                   # 0.438G
        # > koopa::conda_create_env r-monocle3                          # 0.874G
        # > koopa::conda_create_env r-seurat                            # 0.154G
        # > koopa::conda_create_env stream                              # 0.998G
        koopa::conda_create_env kallisto
        koopa::conda_create_env salmon
    fi
    if [[ "$methylation" -eq 1 ]]
    then
        koopa::h2 'Methylation'
        koopa::conda_create_env bismark                                 # 0.406G
    fi
    if [[ "$all" -eq 1 ]]
    then
        koopa::h2 'Other tools'
        koopa::conda_create_env igvtools                                # 0.477G
    fi
    koopa::sys_set_permissions -r "$(koopa::conda_prefix)"
    conda env list
    return 0
}

koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2020-06-29.
    # """
    local flags force env_name name pos prefix version
    koopa::assert_has_args "$#"
    force=0
    version=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    name="${1:?}"
    if [[ -n "${version:-}" ]]
    then
        env_name="${name}@${version}"
    else
        env_name="$name"
    fi
    prefix="$(koopa::conda_prefix)/envs/${env_name}"
    if [[ "$force" -eq 1 ]]
    then
        conda remove --name "$env_name" --all
    fi
    if [[ -d "$prefix" ]]
    then
        koopa::note "'${env_name}' is installed."
        return 0
    fi
    koopa::info "Creating '${env_name}' conda environment."
    koopa::activate_conda
    koopa::assert_is_installed conda
    flags=(
        "--name=${env_name}"
        "--quiet"
        "--yes"
    )
    if [[ -n "${version:-}" ]]
    then
        flags+=("${name}=${version}")
    else
        flags+=("$name")
    fi
    conda create "${flags[@]}"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}

koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2020-06-30.
    # """
    local arg
    koopa::assert_has_args "$#"
    koopa::activate_conda
    koopa::assert_is_installed conda
    for arg in "$@"
    do
        conda remove --yes --name="$arg" --all
    done
    return 0
}
